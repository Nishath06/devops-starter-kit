# =============================================================================
# modules/networking/locals.tf — Networking Module Local Computations
# =============================================================================

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.public_subnets)

  common_tags = merge(
    {
      Module      = "networking"
      Environment = var.environment
    },
    var.tags
  )
}
