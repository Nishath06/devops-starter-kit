# =============================================================================
# modules/eks/outputs.tf — EKS Module Outputs
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint URL for Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane."
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the worker nodes."
  value       = aws_security_group.node.id
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the cluster (used to configure IAM OIDC provider)."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_name" {
  description = "Name of the EKS managed node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group."
  value       = aws_eks_node_group.this.arn
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster."
  value       = aws_eks_cluster.this.version
}
