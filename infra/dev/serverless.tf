module "secret-manager-backend" {
  source     = "../cff-modules/secret-manager"
  project_id = var.project
  secrets = {
    CLOUSQL_PASSWD = {}
  }
  versions = {
    CLOUSQL_PASSWD = {
      v1 = {enabled = true, data = "Passw0rd"}
    }
  }
  iam = {
    CLOUSQL_PASSWD = {
      "roles/secretmanager.secretAccessor" = ["serviceAccount:${module.sa-backend.email}"]
    }
  }
}

module "cloud_run" {
  source     = "../cff-modules/cloud-run"
  project_id = var.project
  region     = var.region
  name       = "lc-backend"
  containers = {
    hello = {
      image = "us-central1-docker.pkg.dev/latam-challenge-infra/lc-repo-dev/lc-api"
      env = {
        PROJECT_ID = var.project,
        CLOUDSQL_INSTANCE_NAME = module.lc-dbinstance.name,
        DATABASE_NAME = google_sql_database.lc-database.name,
        DATABASE_SCHEMA = "lctable",
        DATABASE_USERNAME = "lcadmin"
      }
      env_from = {
        SECRET1 = {
          name = module.secret-manager-backend.ids["CLOUSQL_PASSWD"]
          key  = "latest"
        }
      }
    }
  }
  iam = {
    "roles/run.invoker" = ["allUsers"]
  }
  service_account_create = true
}

resource "google_project_iam_binding" "cloudrun-agent" {
  project = var.project
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:service-392642026277@serverless-robot-prod.iam.gserviceaccount.com",
  ]
}