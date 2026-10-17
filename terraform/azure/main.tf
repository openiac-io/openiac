# ==============================================================================
# OpenIaC Terraform Main: Azure AKS All-in-One Production Platform
# ==============================================================================
# Provisions an Azure Resource Group, Virtual Network (VNet), Subnet, and
# Azure Kubernetes Service (AKS) cluster with SystemAssigned Managed Identity.

provider "azurerm" {
  features {}
}

# ------------------------------------------------------------------------------
# 1. Resource Group & Networking (VNet & Subnet)
# ------------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "${var.cluster_name}-rg"
  location = var.azure_location

  tags = {
    Project   = "OpenIaC"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.cluster_name}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "main" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidr]
}

# ------------------------------------------------------------------------------
# 2. Azure Kubernetes Service (AKS) Cluster
# ------------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.main.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Project   = "OpenIaC"
    ManagedBy = "Terraform"
  }
}
