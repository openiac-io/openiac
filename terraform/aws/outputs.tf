# ==============================================================================
# OpenIaC Terraform Outputs: AWS EKS Production Platform
# ==============================================================================

output "cluster_name" {
  description = "Name of the provisioned Amazon EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint URL for the Amazon EKS Kubernetes API server."
  value       = aws_eks_cluster.main.endpoint
}

output "kubeconfig_command" {
  description = "Copy-paste ready command to configure local kubectl access."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
