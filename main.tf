terraform {
    required_version = "~> 0.12.25"
    required_providers {
        google = "~> 3.23"
    }
    backend "gcs" {
        prefix="faashug-engine"
    }
}

provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_project_service" "container_registry" {
    service = "containerregistry.googleapis.com"
    disable_dependent_services = true
}

resource "google_container_registry" "container_registry" {
    depends_on = [google_project_service.container_registry]
    
    location = var.multi_region_location
}