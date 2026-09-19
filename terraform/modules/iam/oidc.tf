# =============================================================================
# modules/iam/oidc.tf — IAM OIDC Identity Provider for IRSA
# =============================================================================
# WHAT IS IRSA? (IAM Roles for Service Accounts)
# -----------------------------------------------------------------------------
# IRSA allows Kubernetes Pods to assume AWS IAM roles directly without giving
# permissions to the underlying EC2 node or storing AWS access keys in Kubernetes
# secrets.
#
# HOW IT WORKS:
# 1. When a Pod starts with a ServiceAccount annotated with an IAM Role ARN:
#    `eks.amazonaws.com/role-arn: arn:aws:iam::<account>:role/<role-name>`
# 2. The EKS Pod Identity Webhook injects an OIDC JSON Web Token (JWT) into the pod.
# 3. The AWS SDK in the container calls `sts:AssumeRoleWithWebIdentity` passing the JWT.
# 4. AWS STS validates the token against this IAM OIDC Provider.
# 5. STS returns temporary AWS credentials scoped strictly to that specific Pod!
# =============================================================================

data "tls_certificate" "oidc" {
  url = var.oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = var.oidc_issuer_url

  tags = merge(
    var.tags,
    {
      Name      = "${var.cluster_name}-oidc-provider"
      Component = "Security-IRSA"
    }
  )
}
