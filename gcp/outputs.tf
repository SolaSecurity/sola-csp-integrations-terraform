
output "service_account" {
  value = google_service_account.sola_service_account
}

output "project_service" {
  value = google_project_service.enabled_services
}

output "private_key" {
  value = jsondecode(replace(base64decode(google_service_account_key.credentials.private_key), "\n", ""))
}
