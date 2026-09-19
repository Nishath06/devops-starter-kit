# =============================================================================
# modules/networking/nat.tf — Elastic IPs & NAT Gateways
# =============================================================================

# -----------------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# -----------------------------------------------------------------------------
# NAT Gateways (Deployed in Public Subnets)
# -----------------------------------------------------------------------------
resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-nat-gw-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}
