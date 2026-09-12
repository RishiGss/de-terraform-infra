output "dev_terraform_service_account_email" {
  value = {
    email     = google_service_account.dev_terraform_service_account.email
    name      = google_service_account.dev_terraform_service_account.name
    id        = google_service_account.dev_terraform_service_account.id
    member    = google_service_account.dev_terraform_service_account.member
    unique_id = google_service_account.dev_terraform_service_account.unique_id
  }
}

output "dev_tf_state_bucket" {
  value = {
    self_link = google_storage_bucket.dev_terraform_state_bucket.self_link
    url       = google_storage_bucket.dev_terraform_state_bucket.url
  }
}