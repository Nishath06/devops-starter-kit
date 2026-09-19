# =============================================================================
# modules/ecr/lifecycle-policy.tf — ECR Image Lifecycle Policies
# =============================================================================
# Manages automated image retention rules:
#   1. Untagged images: Expired after 1 day (cleans up aborted/intermediate CI builds).
#   2. Tagged images: Retains only the last N (default 10) images per repository.
# =============================================================================

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = toset(var.repository_names)
  repository = aws_ecr_repository.this[each.value].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Retain only the last ${var.max_image_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "release", "sha-", "prod", "dev", "latest"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
