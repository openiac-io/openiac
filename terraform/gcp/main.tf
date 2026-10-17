# ==============================================================================
# OpenIaC Terraform Main: GCP GKE All-in-One Production Platform
# ==============================================================================
# Provisions a dedicated VPC network, subnetwork, Google Kubernetes Engine (GKE)
# Control Plane, and separately managed Worker Node Pool.

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

# ------------------------------------------------------------------------------
# 1. Networking (Dedicated VPC & Subnetwork)
# ------------------------------------------------------------------------------
resource "google_compute_network" "main" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "${var.cluster_name}-subnet"
  region        = var.gcp_region
  network       = google_compute_network.main.name
  ip_cidr_range = var.subnet_cidr
}

# ------------------------------------------------------------------------------
# 2. Google Kubernetes Engine (GKE) Control Plane & Managed Node Pool
# ------------------------------------------------------------------------------
resource "google_container_cluster" "main" {
  name                     = var.cluster_name
  location                 = var.gcp_region
  network                  = google_compute_network.main.name
  subnetwork               = google_compute_subnetwork.main.name
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

resource "google_container_node_pool" "main" {
  name       = "${var.cluster_name}-default-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.main.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      project    = "openiac"
      managed_by = "terraform"
    }
  }
}
