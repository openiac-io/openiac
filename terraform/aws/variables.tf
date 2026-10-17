# ==============================================================================
# OpenIaC Terraform Variables: AWS EKS Production Platform
# ==============================================================================
# Sensible defaults are pre-configured so users can deploy immediately with zero
# configuration changes, or override as needed.

variable "aws_region" {
  description = "Target AWS region for provisioning the VPC and EKS platform."
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster and associated resources."
  type        = string
  default     = "openiac-eks-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version for Amazon EKS."
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "Primary IPv4 CIDR block for the dedicated EKS VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "node_instance_types" {
  description = "EC2 instance types for the default EKS managed node group."
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes in the managed node group."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes in the managed node group."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes in the managed node group."
  type        = number
  default     = 5
}
