variable "dev_project" {
  description = "The Dev GCP project ID"
  type        = string
}

variable "region" {
  description = "The default region to deploy resources in"
  type        = string
  default     = "asia-south1"
}

variable "dev_tf_service_account_id" {
  description = "The ID of the service account that Terraform will use to provision resources in the dev project"
  type        = string
}

variable "dev_tf_state_bucket_name" {
  description = "The name of the GCS bucket that acts as remote backend to store Terraform state for the dev project"
  type        = string
}