variable "admin_email" {
  description = "The email of the admin user"
  type        = string
}

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

variable "dataproc_runtime_sa_id" {
  description = "The ID of the service account that Dataproc will use at runtime"
  type        = string
}

variable "dataproc_runtime_sa_project_roles" {
  description = "The list of project roles to be assigned to the Dataproc runtime service account"
  type        = list(string)
}