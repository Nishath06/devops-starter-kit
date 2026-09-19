# =============================================================================
# modules/eks/node-group.tf — EKS Managed Node Group
# =============================================================================

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name

  node_role_arn = var.node_role_arn
  subnet_ids    = var.subnet_ids

  instance_types = var.node_instance_types
  ami_type       = var.node_ami_type
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_scaling_config.desired_size
    min_size     = var.node_scaling_config.min_size
    max_size     = var.node_scaling_config.max_size
  }

  labels = var.node_labels

  dynamic "taint" {
    for_each = var.node_taints

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${var.node_group_name}"
  })

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
