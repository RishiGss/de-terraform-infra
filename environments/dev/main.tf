locals {
  dev_tf_provisioner_sa_email = "${var.dev_tf_service_account_id}@${var.dev_project}.iam.gserviceaccount.com"

  # GCS Buckets and its purpose
  dev_gcs_buckets = {
    raw          = "datalake"
    curated      = "datalake"
    airflow-logs = "airflow-logs"
  }

  bucket_names = {
    for k, m in module.gcs_buckets : k => m.gcs_bucket_output.name # read attribute from child module output
  }
}

# create GCS buckets
module "gcs_buckets" {
  source = "../../modules/gcs_bucket"

  for_each = local.dev_gcs_buckets

  bucket_name   = "${var.dev_project}-${each.key}"
  location      = var.region
  project       = var.dev_project
  storage_class = "STANDARD"

  labels = {
    purpose = each.value
  }
}

# create BQ datasets
module "bq_datasets" {
  source = "../../modules/bq_dataset"

  for_each = toset([
    "bronze",
    "silver",
    "gold"
  ])

  dataset_id    = each.value
  description   = "${each.value} dataset in ${var.dev_project}"
  friendly_name = each.value
  region        = var.region
  project       = var.dev_project
}

# resources

# dataproc runtime service account and its IAM roles

# create Dataproc runtime service account
resource "google_service_account" "dataproc_runtime_sa" {
  account_id      = var.dataproc_runtime_sa_id
  project         = var.dev_project
  display_name    = "Service Account for Dataproc Runtime"
  description     = "This service account is used by Dataproc at runtime"
  deletion_policy = "PREVENT"
}

# assign project level roles to the Dataproc runtime service account
resource "google_project_iam_member" "dataproc_sa_project_iam" {
  for_each = toset(var.dataproc_runtime_sa_project_roles)

  project = var.dev_project
  role    = each.value
  member  = google_service_account.dataproc_runtime_sa.member # implicit dependency
}

# assign bucket level roles to the Dataproc runtime service account
resource "google_storage_bucket_iam_member" "dataproc_sa_bucket_iam" {
  for_each = local.bucket_names

  bucket = each.value # read attribute from local.bucket_names
  role   = "roles/storage.objectAdmin"
  member = google_service_account.dataproc_runtime_sa.member # implicit dependency
}

# assign IAM roles to the Dataproc runtime service account
resource "google_service_account_iam_member" "dataproc_sa_iam" {
  service_account_id = google_service_account.dataproc_runtime_sa.name # implicit dependency
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.admin_email}"
}