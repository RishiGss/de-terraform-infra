resource "google_bigquery_dataset" "bq_datasets" {
  dataset_id = var.dataset_id

  # Configures time travel to 7 days (168 hours)
  # can be from 48 to 168 hours (2 to 7 days)
  max_time_travel_hours = 168

  description   = var.description
  friendly_name = var.friendly_name
  labels        = var.labels
  location      = var.region
  project       = var.project

  # No delete-protection here (unlike the state bucket)
  # bronze/silver/gold are working data zones expected to be torn down and rebuilt often (dbt schema iteration, SCD-2 redos, Gate drills); 
  # protecting them would block the very apply->destroy->apply cycle this module needs to support.
}