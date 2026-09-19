# =============================================================================
# modules/iam/node-role.tf — EKS Worker Node IAM Role
# =============================================================================
# EC2 instances in the managed node group assume this role. It grants permissions
# to connect to the EKS cluster, pull container images from ECR, configure ENIs
# through VPC CNI, and stream system metrics to CloudWatch.
# =============================================================================

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "${var.cluster_name}-node-role"
      Component = "EKS-WorkerNodes"
    }
  )
}
