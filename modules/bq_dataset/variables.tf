variable "dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
}

variable "description" {
  description = "The description of the BigQuery dataset"
  type        = string
}

variable "friendly_name" {
  description = "The friendly name of the BigQuery dataset"
  type        = string
}

variable "labels" {
  description = "The labels of the BigQuery dataset"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The region of the BigQuery dataset"
  type        = string
}

variable "project" {
  description = "The GCP project ID where the BigQuery dataset will be created"
  type        = string
}