# =============================================================================
# modules/eks/logging.tf — CloudWatch Log Group for EKS Control Plane
# =============================================================================

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days

  tags = var.tags
}
