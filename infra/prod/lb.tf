module "glb-0" {
  source     = "../cff-modules/net-lb-app-ext"
  project_id = var.project
  name       = "lc-lb"
  backend_service_configs = {
    default = {
      backends = [
        { backend = "neg-0" }
      ]
      health_checks = []
    }
  }
  health_check_configs = {}
  neg_configs = {
    neg-0 = {
      cloudrun = {
        region = var.region
        target_service = {
          name = google_cloud_run_service.lc-backend-api.name
        }
      }
    }
  }
}