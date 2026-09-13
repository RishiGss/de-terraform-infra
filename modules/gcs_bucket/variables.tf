variable "location" {
  description = "The default region to deploy resources in"
  type        = string
}

variable "project" {
  description = "The GCP project ID where the GCS bucket will be created"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket to be created"
  type        = string
}

variable "storage_class" {
  description = "The storage class of the GCS bucket to be created"
  type        = string
  default     = "STANDARD"
}

variable "prevent_destroy" {
  description = "Whether to prevent the GCS bucket from being destroyed"
  type        = bool
  default     = false
}

variable "labels" {
  description = "The labels to be applied to the GCS bucket"
  type        = map(string)
  default     = {}
}