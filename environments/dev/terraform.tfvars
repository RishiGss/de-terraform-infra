dev_project               = "learning-dataeng-dev"
dev_tf_service_account_id = "dev-tf-provisioner-sa"
dataproc_runtime_sa_id    = "dataproc-runtime-sa"
admin_email               = "gssrishi@gmail.com"
dataproc_runtime_sa_project_roles = [
  "roles/dataproc.worker",
  "roles/bigquery.dataEditor",
  "roles/bigquery.jobUser"
]