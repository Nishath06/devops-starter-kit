# =============================================================================
# modules/iam/outputs.tf — IAM Module Outputs
# =============================================================================

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.cluster.arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role."
  value       = aws_iam_role.cluster.name
}

output "node_role_arn" {
  description = "ARN of the EKS worker node group IAM role."
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Name of the EKS worker node group IAM role."
  value       = aws_iam_role.node.name
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC Provider."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "Issuer URL of the OIDC provider without https:// (used in IAM trust policies)."
  value       = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}
output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi.arn
}

output "ebs_csi_role_dependency" {
  value = aws_iam_role_policy_attachment.ebs_csi
}
