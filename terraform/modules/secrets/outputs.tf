# =============================================================================
# modules/secrets/outputs.tf
# =============================================================================

output "mongodb_secret_arn" {
  value = aws_secretsmanager_secret.mongodb_uri.arn
}

output "secret_prefix" {
  value = "${var.cluster_name}/backend"
}
