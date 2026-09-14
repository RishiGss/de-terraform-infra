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

  datalake_buckets = {
    raw     = local.bucket_names["raw"]
    curated = local.bucket_names["curated"]
  }

  airflow_logs_bucket = local.bucket_names["airflow-logs"]

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

# --------------------------------------------------
# Dataproc runtime service account and its IAM roles
# --------------------------------------------------

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
  for_each = toset([
    "roles/dataproc.worker",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ])

  project = var.dev_project
  role    = each.value
  member  = google_service_account.dataproc_runtime_sa.member # implicit dependency
}

# assign bucket level roles to the Dataproc runtime service account
resource "google_storage_bucket_iam_member" "dataproc_sa_bucket_iam" {
  for_each = local.datalake_buckets

  bucket = each.value # read attribute from local.datalake_buckets
  role   = "roles/storage.objectAdmin"
  member = google_service_account.dataproc_runtime_sa.member # implicit dependency
}

# allow the admin user to impersonate the Dataproc runtime service account
resource "google_service_account_iam_member" "dataproc_sa_iam" {
  service_account_id = google_service_account.dataproc_runtime_sa.name # implicit dependency
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.admin_email}"
}

# --------------------------------------------------
# Airflow Orchestrator SA and its IAM roles
# --------------------------------------------------

# create Airflow orchestrator service account
resource "google_service_account" "airflow_orchestrator_sa" {
  account_id      = var.airflow_orchestrator_sa_id
  project         = var.dev_project
  display_name    = "Service Account for Airflow Orchestrator — submits Dataproc batches (runs as dataproc-runtime-sa)"
  description     = "Submits and manages Dataproc Serverless batches on behalf of Airflow. Does not execute workloads itself — holds serviceAccountUser on dataproc-runtime-sa"
  deletion_policy = "PREVENT"
}

# assign project level roles to the Airflow orchestrator service account
resource "google_project_iam_member" "airflow_orch_sa_project_iam" {
  project = var.dev_project
  role    = "roles/dataproc.editor"
  member  = google_service_account.airflow_orchestrator_sa.member
}

# assign bucket level roles to the Airflow orchestrator service account
resource "google_storage_bucket_iam_member" "airflow_orch_sa_bucket_iam" {
  bucket = local.airflow_logs_bucket
  role   = "roles/storage.objectUser"
  member = google_service_account.airflow_orchestrator_sa.member
}

# grant the Airflow orchestrator service account the ability to act as the Dataproc runtime service account
resource "google_service_account_iam_member" "airflow_orch_sa_dataproc_runtime_iam" {
  service_account_id = google_service_account.dataproc_runtime_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.airflow_orchestrator_sa.member
}

# allow the admin user to impersonate the Airflow orchestrator service account
resource "google_service_account_iam_member" "airflow_orch_sa_iam" {
  service_account_id = google_service_account.airflow_orchestrator_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.admin_email}"
}