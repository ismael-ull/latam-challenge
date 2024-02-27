module "lc-dbinstance" {
  source     = "../cff-modules/cloudsql-instance"
  project_id = var.project
  name             = "lc-dbinstance"
  region           = var.region
  database_version = "MYSQL_8_0"
  tier             = "db-g1-small"
  deletion_protection = false
  network_config = {
    connectivity = {
      public_ipv4 = true      
    }   
  }
  users = {    
    lcadmin = {
      password = module.secret-manager-cludsqlpasswd.ids["CLOUDSQL_PASSWD"]
    }
  }
}

resource "google_sql_database" "lc-database" {
  name     = "lc-database"
  instance = module.lc-dbinstance.name
}


