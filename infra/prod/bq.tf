
locals {
  lc-db-schema = jsonencode([
    { name = "ID", type = "STRING" },
    { name = "Name", type = "STRING" },
    { name = "LastName", type = "STRING" },
    { name = "FieldA", type = "STRING" },
    { name = "FieldB", type = "STRING" },
    { name = "FieldC", type = "STRING" }
  ])
}

module "bigquery-lc" {
  source     = "../cff-modules/bigquery-dataset"
  project_id = var.project
  id         = "lc_bq_dataset"
  iam = {
    "roles/bigquery.dataOwner" = ["serviceAccount:${module.sa-pubsub.email}"]
  }
  tables = {
    lc-bq-table = {
      friendly_name       = "lc-bq-table"
      schema              = local.lc-db-schema
      deletion_protection = true
    }
  }
}