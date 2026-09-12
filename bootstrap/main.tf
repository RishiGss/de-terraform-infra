# Service Account for Terraform to provision resources in the dev project
resource "google_service_account" "dev_terraform_service_account" {
  account_id      = var.dev_terraform_service_account_id
  display_name    = "Service Account for Terraform to provision resources in the dev project"
  description     = "This service account is used by Terraform to provision resources in the dev project."
  project         = var.dev_project
  deletion_policy = "PREVENT"
}

# IAM roles for the service account to provision resources in the dev project
resource "google_project_iam_member" "dev_tf_sa_iam_member" {

  for_each = toset([
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ])

  project = var.dev_project
  member  = "serviceAccount:${google_service_account.dev_terraform_service_account.email}"
  role    = each.value
}

# IAM role for the admin user to impersonate the service account
resource "google_service_account_iam_member" "admin_sa_iam_member" {
  service_account_id = google_service_account.dev_terraform_service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.admin_email}"
}

# GCS bucket to store Terraform state for the dev project
resource "google_storage_bucket" "dev_terraform_state_bucket" {
  name                        = var.dev_terraform_state_bucket_name
  location                    = var.region
  project                     = var.dev_project
  storage_class               = "STANDARD"
  deletion_policy             = "PREVENT"  # GCP-side enforcement to prevent accidental deletion of the bucket
  public_access_prevention    = "enforced" # GCP-side enforcement to prevent public access to the bucket
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  labels = {
    environment = "dev",
    type        = "terraform-state"
  }
  lifecycle {
    prevent_destroy = true # Terraform-side enforcement to prevent accidental deletion of the bucket
  }
}