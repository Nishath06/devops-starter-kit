# =============================================================================
# modules/networking/subnets.tf — Public and Private Subnets
# =============================================================================

# -----------------------------------------------------------------------------
# Public Subnets (For ALBs and NAT Gateways)
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                                        = "${var.cluster_name}-public-${data.aws_availability_zones.available.names[count.index]}"
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

# -----------------------------------------------------------------------------
# Private Subnets (For EKS Worker Nodes & Internal Load Balancers)
# -----------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name                                        = "${var.cluster_name}-private-${data.aws_availability_zones.available.names[count.index]}"
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "karpenter.sh/discovery"                    = var.cluster_name
    }
  )
}
