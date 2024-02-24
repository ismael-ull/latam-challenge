module "lc-db" {
  source     = "../cff-modules/cloudsql-instance"
  project_id = var.project
  name             = "lc-schema"
  region           = var.region
  database_version = "MYSQL_8_0"
  tier             = "db-g1-small"
  network_config = {
    connectivity = {
      public_ipv4 = true      
    }
   users = {
    # generatea password for user1
    lcadmin = {
      password = module.secret-manager-backend.ids["CLOUSQL_PASSWD"]
    }
  }
  }
}