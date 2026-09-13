output "bq_dataset_output" {
  value = {
    id = google_bigquery_dataset.bq_datasets.id
  }
}