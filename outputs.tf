output "project_id" {
  value       = var.project_id
  description = "project_id"
}

output "region" {
  value       = var.region
  description = "region"
}

output "cloudrun_applied" {
  value       = var.cloudrun_should_apply
  description = "Cloud Run services applied"
}

output "gke_applied" {
  value       = var.gke_should_apply
  description = "GKE cluster applied"
}

output "long_running_logger_image" {
  value       = local.long_running_logger_image
  description = "long-running-logger image used"
}

output "gke_cluster_name" {
  value       = join(" ", google_container_cluster.primary.*.name)
  description = "GKE Cluster name"
}

output "cloudrun_region" {
  value       = var.cloudrun_region
  description = "Region for Cloud Run (fully managed) services"
}

output "cloudrun_long_running_logger_service_url" {
  value       = join(" ", google_cloud_run_service.long_running_logger[*].status[0].url)
  description = "long-running-logger CloudRun Service URL"
}
