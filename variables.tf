variable "project_id" {
  type    = string
  default = "faashug-dev"
}

variable "region" {
  type    = string
  default = "europe-west3"
}

variable "zone" {
  type    = string
  default = "europe-west3-a"
}

variable "multi_region_location" {
  type    = string
  default = "EU"
}

variable "container_registry_location" {
  type    = string
  default = "eu.gcr.io"
}

variable "cloudrun_should_apply" {
  default     = true
  description = "Should Cloud Run (fully managed) services be applied"
}

variable "gke_should_apply" {
  default     = false
  description = "Should GKE cluster be applied"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "gke_machine_type" {
  type = string
  default     = "n1-standard-1"
  description = "number of gke nodes"
}

variable "cloudrun_region" {
  type = string
  default = "europe-west1"
  description = "Region for Cloud Run (fully managed) services"
}

variable "long_running_logger_image_name" {
  type        = string
  default     = "long-running-logger"
  description = "long-running-logger image name"
}

variable "long_running_logger_image_tag" {
  type        = string
  default     = "1.0.0"
  description = "Tag of used long-running-logger (in SemVer 2.0.0 convention)"
}

locals {
  long_running_logger_image = "${var.container_registry_location}/${var.project_id}/${var.long_running_logger_image_name}:${var.long_running_logger_image_tag}"
}