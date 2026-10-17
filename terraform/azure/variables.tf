# ==============================================================================
# OpenIaC Terraform Variables: Azure AKS Production Platform
# ==============================================================================
# Sensible defaults are pre-configured for immediate zero-config deployment.

variable "azure_location" {
  description = "Target Azure region for the Resource Group, VNet, and AKS cluster."
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes Service (AKS) cluster."
  type        = string
  default     = "openiac-aks-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version for Azure AKS."
  type        = string
  default     = "1.29"
}

variable "vnet_cidr" {
  description = "Address space CIDR for the Azure Virtual Network (VNet)."
  type        = string
  default     = "10.30.0.0/16"
}

variable "subnet_cidr" {
  description = "Address prefix CIDR for the AKS worker node subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "node_vm_size" {
  description = "Azure VM SKU for the default AKS node pool."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Number of worker nodes in the default AKS node pool."
  type        = number
  default     = 2
}
