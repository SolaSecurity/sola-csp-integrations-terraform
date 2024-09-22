terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.6.0"
    }
  }
}

provider "google" {
  project = var.project_id
}
