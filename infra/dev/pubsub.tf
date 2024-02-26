/**module "pubsub" {
  source     = "../cff-modules/pubsub"
  project_id = var.project
  name       = "lc-bq-update"
  //iam = {
  //  "roles/pubsub.viewer"     = ["group:foo@example.com"]
  //  "roles/pubsub.subscriber" = ["user:user1@example.com"]
  //}
  subscriptions = {
    lc-bq-update-subs = {
      bigquery = {
        table               = "${var.project}:${module.bigquery-lc.dataset_id}.lc-bq-table"
        use_topic_schema    = true
        write_metadata      = false
        drop_unknown_fields = true
      }
    }
  }
}**/