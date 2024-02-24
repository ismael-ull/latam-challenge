##############################################################################################
#                                           DATA                                             #
##############################################################################################


##############################################################################################
#                                         VARIABLES                                          #
##############################################################################################


##############################################################################################
#                                    MODULES AND RESOURCES                                   #
##############################################################################################

module "sa-backend" {
  source     = "../cff-modules/iam-service-account"
  project_id = var.project
  name       = "lc-backend-sa"
  iam_project_roles = {
    "${var.project}" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/cloudsql.client",
      "roles/pubsub.publisher",
      "roles/run.invoker"
    ]
  }
}

module "sa-pubsub" {
  source     = "../cff-modules/iam-service-account"
  project_id = var.project
  name       = "lc-pubsub-sa"
  iam_project_roles = {
    "${var.project}" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/pubsub.editor"
    ]
  }
}

/**resource "google_project_iam_binding" "analytics" {
  project = var.project
  role    = "roles/bigquery.dataViewer"

  members = [
    "group:lc-analytics@mzoestudio.com",
  ]
}**/