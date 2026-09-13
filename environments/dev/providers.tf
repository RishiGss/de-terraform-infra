provider "google" {
  # Configuration options
  project                     = var.dev_project
  region                      = var.region
  impersonate_service_account = local.dev_tf_provisioner_sa_email
  default_labels = {
    environment = "dev"
  }
  add_terraform_attribution_label = true
}