# =============================================================================
# modules/networking/data.tf — Availability Zones Data Source
# =============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}
