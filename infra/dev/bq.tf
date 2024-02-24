
module "bigquery-lc" {
  source     = "../cff-modules/bigquery-dataset"
  project_id = var.project
  id         = "lc_bq_dataset"
  iam = {
    "roles/bigquery.dataOwner" = ["serviceAccount:${module.sa-pubsub.email}"]
  }
}