# ==============================================================================
# OpenIaC Terraform Variables: GCP GKE Production Platform
# ==============================================================================
# Sensible defaults are pre-configured for immediate zero-config deployment.

variable "project_id" {
  description = "Target Google Cloud Project ID for provisioning the GKE platform."
  type        = string
  default     = "openiac-gcp-prod"
}

variable "gcp_region" {
  description = "Target Google Cloud region for the VPC and GKE cluster."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the Google Kubernetes Engine (GKE) cluster."
  type        = string
  default     = "openiac-gke-prod"
}

variable "subnet_cidr" {
  description = "Primary IPv4 CIDR range for the GKE VPC subnetwork."
  type        = string
  default     = "10.20.0.0/16"
}

variable "node_machine_type" {
  description = "Compute Engine machine type for GKE worker nodes."
  type        = string
  default     = "e2-standard-2"
}

variable "node_count" {
  description = "Initial number of worker nodes per zone in the GKE node pool."
  type        = number
  default     = 1
}
