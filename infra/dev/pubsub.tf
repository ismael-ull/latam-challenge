module "pubsub" {
  source     = "../cff-modules/pubsub"
  project_id = "my-project"
  name       = "my-topic"
  iam = {
    "roles/pubsub.viewer"     = ["group:foo@example.com"]
    "roles/pubsub.subscriber" = ["user:user1@example.com"]
  }
}