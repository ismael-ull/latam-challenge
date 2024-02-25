module "lc-db" {
  source     = "../cff-modules/cloudsql-instance"
  project_id = var.project
  name             = "lc-db-01"
  region           = var.region
  database_version = "MYSQL_8_0"
  tier             = "db-g1-small"
  deletion_protection = false
  network_config = {
    connectivity = {
      public_ipv4 = true      
    }
   users = {    
    lcadmin = {
      password = module.secret-manager-backend.ids["CLOUSQL_PASSWD"]
    }
  }
  }
}