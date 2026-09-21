# =============================================================================
# modules/iam/backend-secrets.tf
# Backend IRSA Role for AWS Secrets Manager
# =============================================================================

variable "backend_namespace" {
  type    = string
  default = "default"
}

variable "backend_service_account" {
  type    = string
  default = "backend-sa"
}

variable "secret_prefix" {
  description = "Secrets Manager prefix."
  type        = string
}

resource "aws_iam_role" "backend_secrets" {

  name = "${var.cluster_name}-backend-secrets-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {

            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" = "sts.amazonaws.com"

            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:${var.backend_namespace}:${var.backend_service_account}"

          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Component = "Backend-IRSA"
    Name      = "${var.cluster_name}-backend-secrets-role"
  })
}

# ---------------------------------------------------------------------------
# IAM Policy
# ---------------------------------------------------------------------------

resource "aws_iam_policy" "backend_secrets" {

  name = "${var.cluster_name}-backend-secrets-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "ReadBackendSecrets"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.secret_prefix}/*"
        ]
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "backend_secrets" {
  role       = aws_iam_role.backend_secrets.name
  policy_arn = aws_iam_policy.backend_secrets.arn
}
