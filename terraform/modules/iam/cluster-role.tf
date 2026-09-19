# =============================================================================
# modules/iam/cluster-role.tf — EKS Cluster IAM Control Plane Role
# =============================================================================
# The EKS cluster control plane assumes this IAM role to manage AWS resources
# on your behalf (such as creating ENIs for cross-VPC communication with worker
# nodes and provisioning Network Load Balancers for services).
# =============================================================================

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "${var.cluster_name}-cluster-role"
      Component = "EKS-ControlPlane"
    }
  )
}
