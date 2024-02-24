module "secret-manager-backend" {
  source     = "../cff-modules/secret-manager"
  project_id = var.project
  secrets = {
    CLOUSQL_PASSWD = { data = "Passw0rd"}
  }
  iam = {
    CLOUSQL_PASSWD = {
      "roles/secretmanager.secretAccessor" = ["serviceAccount:${module.sa-backend.email}"]
    }
  }
}