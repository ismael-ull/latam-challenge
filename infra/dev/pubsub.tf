module "pubsub" {
  source     = "../cff-modules/pubsub"
  project_id = var.project
  name       = "lc-bq-update"
  //iam = {
  //  "roles/pubsub.viewer"     = ["group:foo@example.com"]
  //  "roles/pubsub.subscriber" = ["user:user1@example.com"]
  //}
}