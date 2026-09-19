# =============================================================================
# modules/ecr/repositories.tf — Amazon ECR Repositories
# =============================================================================
# Uses `for_each` to create named container repositories.
# Best Practice: `for_each` ensures stability; removing one repository name from
# the list will NOT shift indexes or destroy unrelated repositories (unlike `count`).
# =============================================================================

resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repository_names)
  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(
    var.tags,
    {
      Name    = each.value
      Service = each.value
    }
  )
}
