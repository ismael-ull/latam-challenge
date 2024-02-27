module "pubsub" {
  source     = "../cff-modules/pubsub"
  project_id = var.project
  name       = "lc-bq-update"
  iam = {
    "roles/pubsub.subscriber" = ["serviceAccount:${module.sa-backend.email}"],
    "roles/pubsub.publisher" = ["serviceAccount:${module.sa-backend.email}"]
  }
  /**subscriptions = {
    lc-bq-update-subs = {
      bigquery = {
        table               = "${var.project}:${module.bigquery-lc.dataset_id}.lc-bq-table"
        use_topic_schema    = true
        write_metadata      = false
        drop_unknown_fields = true
      }
    }
  }**/
}