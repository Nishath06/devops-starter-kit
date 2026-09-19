# =============================================================================
# outputs.tf — Root Terraform Module Outputs
# =============================================================================
# Exposes essential infrastructure identifiers consumed by Helm, ArgoCD,
# Kubernetes manifests, CI/CD pipelines (GitHub Actions), and operators.
# =============================================================================

# -----------------------------------------------------------------------------
# Networking Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the provisioned VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs for the public subnets (used for public ALBs)."
  value       = module.networking.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs for the private subnets (used for worker nodes & internal ALBs)."
  value       = module.networking.private_subnets
}

output "nat_gateway_ips" {
  description = "Public Elastic IP addresses assigned to the NAT Gateways."
  value       = module.networking.nat_gateway_ips
}

# -----------------------------------------------------------------------------
# IAM & IRSA Outputs
# -----------------------------------------------------------------------------
output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = module.iam.cluster_role_arn
}

output "node_role_arn" {
  description = "ARN of the EKS managed node group IAM role."
  value       = module.iam.node_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC Provider used for IAM Roles for Service Accounts (IRSA)."
  value       = module.iam.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "Issuer URL of the IAM OIDC Provider without the https:// prefix."
  value       = module.iam.oidc_provider_url
}

# -----------------------------------------------------------------------------
# EKS Cluster Outputs
# -----------------------------------------------------------------------------
output "cluster_name" {
  description = "The name of the Amazon EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL for your Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS worker nodes."
  value       = module.eks.node_security_group_id
}

output "node_group_name" {
  description = "Name of the EKS managed node group."
  value       = module.eks.node_group_name
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group."
  value       = module.eks.node_group_arn
}

output "cluster_version" {
  description = "Kubernetes version running on the EKS cluster."
  value       = module.eks.cluster_version
}

# -----------------------------------------------------------------------------
# ECR Outputs
# -----------------------------------------------------------------------------
output "ecr_repository_urls" {
  description = "Map of container repository names to their corresponding ECR clone/push URLs."
  value       = module.ecr.repository_urls
}

output "aws_region" {
  description = "AWS Region where infrastructure is deployed."
  value       = var.aws_region
}

# -----------------------------------------------------------------------------
# Post-Deployment Helper
# -----------------------------------------------------------------------------
output "configure_kubectl" {
  description = "Convenience AWS CLI command to generate kubeconfig credentials."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

