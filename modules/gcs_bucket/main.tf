resource "google_storage_bucket" "gcs_buckets" {
  name          = var.bucket_name
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
  versioning {
    enabled = true
  }
  labels                      = var.labels
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # Set the deletion policy based on the prevent_destroy variable.
  # If prevent_destroy is true, the bucket will have a deletion policy of "PREVENT", which means it cannot be destroyed.
  # If prevent_destroy is false, the bucket will have a deletion policy of "DELETE", allowing it to be destroyed.
  deletion_policy = var.prevent_destroy ? "PREVENT" : "DELETE"

  # GCS Object Lifecycle Management rule.
  # When versioning is enabled, GCS keeps noncurrent versions of objects. 
  # If there are noncurrent/old versions of objects that have been archived for 30 days, delete them.
  # This rule helps manage storage costs by removing outdated versions.
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 30
      with_state                 = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }
}