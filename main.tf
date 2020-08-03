terraform {
  required_version = "~> 0.12.25"
  required_providers {
    google = "~> 3.32"
    google-beta = "~> 3.32"
  }
  backend "gcs" {
    prefix = "faashug-engine"
  }
}

# default if not specified
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "container_registry" {
  service                     = "containerregistry.googleapis.com"
  disable_dependent_services  = true
}

resource "google_container_registry" "container_registry" {
  location    = var.multi_region_location

  depends_on  = [google_project_service.container_registry]
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

# Required by Cloud Run
resource "google_project_service" "cloud_run" {
  service                     = "run.googleapis.com"
  disable_dependent_services  = true
}

# [GKE]
resource "google_compute_network" "vpc" {
  count = var.gke_should_apply ? 1 : 0

  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"

  depends_on  = [google_project_service.compute_engine]
}

# [GKE]
resource "google_compute_subnetwork" "gke" {
  count = var.gke_should_apply ? 1 : 0

  name            = "${var.project_id}-gke-subnet"
  ip_cidr_range   = "10.10.0.0/16"
  region          = var.region
  network         = google_compute_network.vpc[count.index].name
}

# [GKE] Cluster definition 
resource "google_container_cluster" "primary" {
  provider = google-beta

  count = var.gke_should_apply ? 1 : 0

  name     = "${var.project_id}-gke"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc[count.index].name
  subnetwork = google_compute_subnetwork.gke[count.index].name

  release_channel {
    channel = "REGULAR"
  }

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# [GKE] Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  count = var.gke_should_apply ? 1 : 0

  name       = "${google_container_cluster.primary[count.index].name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary[count.index].name
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

    machine_type = var.gke_machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# [Cloud Run] Service definition
resource "google_cloud_run_service" "long_running_logger" {
  count = var.cloudrun_should_apply ? 1 : 0

  name     = "${var.project_id}-long-running-logger-cloudrun"
  location = var.cloudrun_region

  template {
    spec {
      containers {
        image = local.long_running_logger_cloudrun_image

        env {
          name  = var.long_running_logger_execution_minutes_env_name
          value = var.long_running_logger_execution_minutes_env_value
        }
      }

      timeout_seconds = var.cloudrun_timeout_seconds
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.cloud_run]
}
