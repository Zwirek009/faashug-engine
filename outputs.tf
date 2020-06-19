output "project_id" {
  value       = var.project_id
  description = "project_id"
}

output "region" {
  value       = var.region
  description = "region"
}

output "gke_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
