terraform {
  required_version = "~> 0.12.25"
  required_providers {
    google = "~> 3.23"
  }
  backend "gcs" {
    prefix = "faashug-engine"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "container_registry" {
  service                     = "containerregistry.googleapis.com"
  disable_dependent_services  = true
}

# Required by GKE module. Used for managing VPC etc.
resource "google_project_service" "compute_engine" {
  service                     = "compute.googleapis.com"
  disable_dependent_services  = true
}

# Required by GKE module.
resource "google_project_service" "kubernetes_engine" {
  service                     = "container.googleapis.com"
  disable_dependent_services  = true
}

resource "google_container_registry" "container_registry" {
  location    = var.multi_region_location

  depends_on  = [google_project_service.container_registry]
}

resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"

  depends_on  = [google_project_service.compute_engine]
}

resource "google_compute_subnetwork" "gke" {
  name            = "${var.project_id}-gke-subnet"
  ip_cidr_range   = "10.10.0.0/16"
  region          = var.region
  network         = google_compute_network.vpc.name
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.gke.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
