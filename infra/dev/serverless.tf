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
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      env = {
        PROJECT_ID = var.project,
        CLOUDSQL_INSTANCE_NAME = "VALUE2",
        DATABASE_NAME = "VALUE3",
        DATABASE_SCHEMA = "VALUE4",
        DATABASE_USERNAME = "VALUE5"
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