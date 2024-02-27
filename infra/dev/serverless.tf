module "secret-manager-cludsqlpasswd" {
  source     = "../cff-modules/secret-manager"
  project_id = var.project  
  secrets = {
    CLOUDSQL_PASSWD = {}
  }
  versions = {
    CLOUDSQL_PASSWD = {
      v1 = {enabled = true, data = "Passw0rd"}
    }
  }
  iam = {
    CLOUDSQL_PASSWD = {
      "roles/secretmanager.secretAccessor" = ["serviceAccount:${module.sa-backend.email}"]
    }
  }
}

resource "google_project_iam_binding" "cloudrun-agent-secretmanager" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:service-392642026277@serverless-robot-prod.iam.gserviceaccount.com",
    "serviceAccount:${module.sa-backend.email}",
  ]
}

resource "google_project_iam_binding" "cloudrun-agent" {
  project = var.project
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:service-392642026277@serverless-robot-prod.iam.gserviceaccount.com",
    "serviceAccount:${module.sa-backend.email}"
  ]
}

module "cloud_run" {
  source     = "../cff-modules/cloud-run"
  project_id = var.project
  region     = var.region
  name       = "lc-backend"
  containers = {
    lc-api = {
      image = "us-central1-docker.pkg.dev/latam-challenge-infra/lc-repo-dev/lc-api-go"
      env = {
        PROJECT_ID = var.project,
        DB_INSTANCE = module.lc-dbinstance.name,
        DB_DATABASE = google_sql_database.lc-database.name,
        //DB_SCHEMA = "lctable",
        DB_USER = "lcadmin",
        PUBSUB_TOPIC = module.pubsub.id,
        CLOUDSQL_CONNECTION_NAME = "latam-challenge-dev:us-central1:lc-dbinstance"
      }
      env_from = {
        CLOUDSQL_PASSWD = {
          name = module.secret-manager-cludsqlpasswd.ids["CLOUDSQL_PASSWD"]
          key  = "latest"
        }
      }
    }
  }
  iam = {
    "roles/run.invoker" = ["allUsers"]
  }
  //service_account_create = true
  service_account = module.sa-backend.email
}

/**
module "cloud_run_v2" {
  source     = "../cff-modules/cloud-run-v2"
  project_id = var.project
  name       = "lc-backend-go"
  region     = var.region
  containers = {
    lc-api-go = {
      image = "us-central1-docker.pkg.dev/latam-challenge-infra/lc-repo-dev/lc-api-go"
      env = {
        PROJECT_ID = var.project,
        DB_INSTANCE = module.lc-dbinstance.name,
        DB_DATABASE = google_sql_database.lc-database.name,
        DB_SCHEMA = "lctable",
        DB_USER = "lcadmin",
        PUBSUB_TOPIC = "dummy",
        CLOUDSQL_CONNECTION_NAME = "latam-challenge-dev:us-central1:lc-dbinstance"
      }
      env_from_key = {
        CLOUDSQL_PASSWD = {
          secret = module.secret-manager-cludsqlpasswd.secrets["CLOUDSQL_PASSWD"].name
          version = module.secret-manager-cludsqlpasswd.versions["CLOUDSQL_PASSWD:v1"]
        }
      }
    }
  }
  iam = {
    "roles/run.invoker" = ["allUsers"]
  }
  service_account = module.sa-backend.email
}**/


resource "google_cloud_run_service" "lc-backend-api" {
  name     = "lc-api-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/latam-challenge-infra/lc-repo-dev/lc-api-go"

        env {
          name  = "PROJECT_ID"
          value = var.project
        }

        env {
          name  = "DB_INSTANCE"
          value = module.lc-dbinstance.name
        }

        env {
          name  = "DB_DATABASE"
          value = google_sql_database.lc-database.name
        }

        env {
          name  = "DB_USER"
          value = "lcadmin"
        }

        env {
          name  = "PUBSUB_TOPIC"
          value = module.pubsub.id
        }

        env {
          name  = "CLOUDSQL_CONNECTION_NAME"
          value = "latam-challenge-dev:us-central1:lc-dbinstance"
        }

        env {
          name = "DB_PASSWD"
          value_from {
            secret_key_ref {
              name = "CLOUDSQL_PASSWD"
              key  = "latest"
            }
          }
        }
      }

      service_account_name = module.sa-backend.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_service.lc-backend-api.location
  service  = google_cloud_run_service.lc-backend-api.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}