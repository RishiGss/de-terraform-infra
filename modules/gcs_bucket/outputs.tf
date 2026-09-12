output "gcs_bucket_output" {
  value = {
    url  = google_storage_bucket.gcs_buckets.url
    name = google_storage_bucket.gcs_buckets.name
  }
}