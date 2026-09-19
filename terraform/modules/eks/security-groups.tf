# =============================================================================
# modules/eks/security-groups.tf — Cluster and Worker Node Security Groups
# =============================================================================
# Security Groups act as stateful virtual firewalls at the ENI level.
# EKS requires two primary security groups:
#   1. Cluster SG: Protects the Kubernetes API Server control plane.
#   2. Node SG: Protects worker nodes and allows inter-node communication.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Cluster Control Plane Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS control plane communication with worker nodes and operators."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-cluster-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# -----------------------------------------------------------------------------
# 2. Worker Node Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for all worker nodes in the cluster."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-node-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "karpenter.sh/discovery"                    = var.cluster_name
    }
  )
}

# -----------------------------------------------------------------------------
# Cluster Security Group Rules
# -----------------------------------------------------------------------------

# Ingress: Allow external API clients (kubectl, CI/CD) if public access is enabled
resource "aws_security_group_rule" "cluster_ingress_public_api" {
  count             = var.cluster_endpoint_public_access ? 1 : 0
  description       = "Allow allowed CIDRs to communicate with the EKS API server."
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.cluster_endpoint_public_access_cidrs
  security_group_id = aws_security_group.cluster.id
}

# Ingress: Allow worker nodes to reach the EKS API Server on port 443
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  description              = "Allow worker nodes to communicate with the cluster API Server."
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.cluster.id
}

# Egress: Allow cluster control plane to reach worker nodes on kubelet ports (1025-65535)
resource "aws_security_group_rule" "cluster_egress_node_kubelet" {
  description              = "Allow cluster control plane to communicate with worker nodes (kubelet, logs, exec)."
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.cluster.id
}

# Egress: Allow cluster control plane to reach pods running admission webhooks on port 443
resource "aws_security_group_rule" "cluster_egress_node_webhooks" {
  description              = "Allow cluster control plane to communicate with pods running admission webhooks."
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.cluster.id
}

# -----------------------------------------------------------------------------
# Node Security Group Rules
# -----------------------------------------------------------------------------

# Ingress: Allow all node-to-node communication for pods, services, and CoreDNS
resource "aws_security_group_rule" "node_ingress_self" {
  description       = "Allow nodes to communicate with each other on all ports (pod networking & CoreDNS)."
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.node.id
}

# Ingress: Allow control plane to communicate with worker nodes on kubelet ports
resource "aws_security_group_rule" "node_ingress_cluster_kubelet" {
  description              = "Allow control plane to communicate with worker node kubelet on ports 1025-65535."
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node.id
}

# Ingress: Allow control plane to communicate with pods running admission webhooks on 443
resource "aws_security_group_rule" "node_ingress_cluster_webhooks" {
  description              = "Allow control plane to reach webhooks running on worker nodes on port 443."
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node.id
}

# Egress: Allow worker nodes outbound access to all destinations (Internet via NAT, AWS APIs)
resource "aws_security_group_rule" "node_egress_all" {
  description       = "Allow worker nodes outbound communication to all destinations."
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
}
