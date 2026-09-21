# =============================================================================
# modules/secrets/secrets.tf
# AWS Secrets Manager Resources
# =============================================================================

locals {
  secret_prefix = "${var.cluster_name}/backend"
}

# ---------------------------------------------------------------------------
# MongoDB URI Example
# ---------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "mongodb_uri" {
  name                    = "${local.secret_prefix}/mongodb-uri"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Component = "SecretsManager"
    Secret    = "mongodb-uri"
  })
}

resource "aws_secretsmanager_secret_version" "mongodb_uri" {
  secret_id     = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = var.mongodb_uri
}
