# =============================================================================
# modules/eks/cluster.tf — EKS Cluster Control Plane Resource
# =============================================================================

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = var.cluster_endpoint_public_access
    endpoint_private_access = var.cluster_endpoint_private_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  enabled_cluster_log_types = var.cluster_log_types

  dynamic "encryption_config" {
    for_each = var.enable_encryption && var.encryption_key_arn != "" ? [1] : []

    content {
      provider {
        key_arn = var.encryption_key_arn
      }

      resources = ["secrets"]
    }
  }

  tags = var.tags
}
