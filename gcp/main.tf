data "google_project" "current" {
  project_id = var.project_id
}

locals {
  allowed_policies = [
    "iam.securityReviewer",
    "viewer",
    "cloudasset.viewer"
  ]
  services_list = [
    "admin",
    "appengine",
    "bigquery",
    "cloudbilling",
    "cloudfunctions",
    "cloudscheduler",
    "dataproc",
    "dns",
    "cloudresourcemanager",
    "sql-component",
    "sqladmin",
    "compute",
    "iam",
    "container",
    "servicemanagement",
    "serviceusage",
    "logging",
    "cloudasset",
    "redis",
    "storage-api",
    "groupssettings",
    "spanner",
    "file",
    "recommender"
  ]
}

resource "google_service_account" "sola_service_account" {
  account_id   = var.service_account_name
  display_name = "Sola's ReadOnly Integration for ${data.google_project.current.name}"
  project      = data.google_project.current.project_id

  depends_on = [google_project_service.enabled_services]
}

resource "google_project_iam_member" "service_account_project_membership" {
  for_each = toset(local.allowed_policies)
  project  = data.google_project.current.project_id
  role     = "roles/${each.value}"
  member   = "serviceAccount:${google_service_account.sola_service_account.email}"
}

resource "google_service_account_key" "credentials" {
  service_account_id = google_service_account.sola_service_account.name
}

resource "google_project_service" "enabled_services" {
  for_each           = toset(local.services_list)
  project            = data.google_project.current.project_id
  service            = "${each.value}.googleapis.com"
  disable_on_destroy = false
}
