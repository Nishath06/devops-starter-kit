# =============================================================================
# modules/ecr/outputs.tf
# =============================================================================

output "repository_urls" {
  description = "Map of ECR repository names to their repository URLs."

  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of ECR repository names to their ARNs."

  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.arn
  }
}

output "registry_id" {
  description = "AWS Account Registry ID."

  value = values(aws_ecr_repository.this)[0].registry_id
}
