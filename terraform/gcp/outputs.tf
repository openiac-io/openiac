# ==============================================================================
# OpenIaC Terraform Outputs: GCP GKE Production Platform
# ==============================================================================

output "cluster_name" {
  description = "Name of the provisioned Google Kubernetes Engine (GKE) cluster."
  value       = google_container_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint IP for the GKE Kubernetes API server."
  value       = google_container_cluster.main.endpoint
}

output "kubeconfig_command" {
  description = "Copy-paste ready command to configure local kubectl access."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --region ${var.gcp_region} --project ${var.project_id}"
}
