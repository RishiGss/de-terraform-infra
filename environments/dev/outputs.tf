# Module outputs
# --------------
# Terraform "for" expression over a map produced by for_each.
# Since module.gcs_buckets was created with for_each, it's a MAP of
# module instances, keyed by each.key ("raw", "curated", "airflow-logs").
# for k, v in module.gcs_buckets: k => v.gcs_bucket_output
#   k = the for_each key (e.g. "raw")
#   v = that module instance itself
#   v.gcs_bucket_output = the specific output declared inside that module
#
# Result: a single map like
#   { raw = {...}, curated = {...}, "airflow-logs" = {...} }


# "=>" is a separator for one key and value pair inside an object.

# Format
# output <label> {
#   value = {for k, v in <module_name>: k => v.<output_name in module>}
# }

output "gcs_buckets" {
  value = { for k, v in module.gcs_buckets : k => v.gcs_bucket_output }
}

output "bq_datasets" {
  value = { for k, v in module.bq_datasets : k => v.bq_dataset_output }
}

output "dataproc_runtime_sa_output" {
  value = {
    id     = google_service_account.dataproc_runtime_sa.id
    name   = google_service_account.dataproc_runtime_sa.name
    email  = google_service_account.dataproc_runtime_sa.email
    member = google_service_account.dataproc_runtime_sa.member
  }
}

output "airflow_orchestrator_sa_output" {
  value = {
    id     = google_service_account.airflow_orchestrator_sa.id
    name   = google_service_account.airflow_orchestrator_sa.name
    email  = google_service_account.airflow_orchestrator_sa.email
    member = google_service_account.airflow_orchestrator_sa.member
  }
}