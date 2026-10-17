# ==============================================================================
# OpenIaC Terraform Outputs: Azure AKS Production Platform
# ==============================================================================

output "cluster_name" {
  description = "Name of the provisioned Azure Kubernetes Service (AKS) cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "resource_group_name" {
  description = "Name of the Azure Resource Group hosting the AKS cluster."
  value       = azurerm_resource_group.main.name
}

output "kubeconfig_command" {
  description = "Copy-paste ready command to configure local kubectl access."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}
