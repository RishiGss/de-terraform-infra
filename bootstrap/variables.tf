variable "dev_project" {
  description = "The Dev GCP project ID"
  type        = string
}

variable "prd_project" {
  description = "The Prod GCP project ID"
  type        = string
}

variable "region" {
  description = "The default region to deploy resources in"
  type        = string
  default     = "asia-south1"
}

variable "admin_email" {
  description = "The email of the admin user who will have access to the service account"
  type        = string
}

variable "dev_terraform_service_account_id" {
  description = "The name of the service account that Terraform will use to provision resources in the dev project"
  type        = string
}

variable "dev_terraform_state_bucket_name" {
  description = "The name of the GCS bucket that acts as remote backend to store Terraform state for the dev project"
  type        = string
}