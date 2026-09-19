# =============================================================================
# modules/networking/igw.tf — Internet Gateway
# =============================================================================

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-igw"
    }
  )
}
