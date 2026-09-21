# =============================================================================
# modules/eks/addons.tf — EKS Managed Add-ons
# =============================================================================
# AWS-managed operational software components essential for cluster networking,
# internal service discovery, identity management, and persistent storage.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. AWS VPC CNI (Container Network Interface)
# -----------------------------------------------------------------------------
# Purpose: Gives every Kubernetes pod an actual IPv4 address from your AWS VPC CIDR.
# Pods can communicate with AWS resources (RDS, ElastiCache, S3) with native VPC routing.
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Addon = "vpc-cni"
    }
  )
}

# -----------------------------------------------------------------------------
# 2. kube-proxy
# -----------------------------------------------------------------------------
# Purpose: Runs on each node to maintain network rules (iptables or IPVS).
# Translates Kubernetes Service IPs (ClusterIP) into backing Pod endpoints.
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Addon = "kube-proxy"
    }
  )
}

# -----------------------------------------------------------------------------
# 3. CoreDNS
# -----------------------------------------------------------------------------
# Purpose: Internal cluster DNS server enabling service-to-service discovery.
# (e.g., http://backend.default.svc.cluster.local)
# Depends on worker node group being ready so pods can be scheduled.
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Addon = "coredns"
    }
  )

  depends_on = [
    aws_eks_node_group.this
  ]
}

# -----------------------------------------------------------------------------
# 4. EKS Pod Identity Agent
# -----------------------------------------------------------------------------
# Purpose: Modern, high-performance credential agent that runs on every node.
# Provides temporary IAM credentials directly to pods without external STS OIDC calls.
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "pod_identity" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Addon = "eks-pod-identity-agent"
    }
  )
}

# -----------------------------------------------------------------------------
# 5. AWS EBS CSI Driver
# -----------------------------------------------------------------------------
# Purpose: Container Storage Interface (CSI) plugin for dynamic provisioning
# and lifecycle management of Amazon EBS storage volumes for StatefulSets and PVCs.
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"

  service_account_role_arn = var.ebs_csi_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this,
    var.ebs_csi_role_dependency
  ]

  timeouts {
    create = "30m"
    update = "30m"
  }

  tags = merge(var.tags, {
    Addon = "aws-ebs-csi-driver"
  })
}
# ---------------------------------------------------------------------------
# Secrets Store CSI Driver
# ---------------------------------------------------------------------------

resource "aws_eks_addon" "secrets_store_csi" {

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "secrets-store-csi-driver"
  addon_version = var.secrets_store_csi_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(var.tags, {
    Component = "SecretsStoreCSI"
  })
}

# ---------------------------------------------------------------------------
# AWS Provider for Secrets Store CSI Driver
# ---------------------------------------------------------------------------

resource "helm_release" "aws_secrets_provider" {

  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"

  namespace        = "kube-system"
  create_namespace = false

  depends_on = [
    aws_eks_addon.secrets_store_csi
  ]
}
