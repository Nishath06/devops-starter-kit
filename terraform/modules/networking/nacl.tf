# =============================================================================
# modules/networking/nacl.tf — Network Access Control Lists (NACLs)
# =============================================================================
# NACLs provide a stateless layer of network security at the subnet boundary.
# Unlike Security Groups (which are stateful and applied to ENIs/instances),
# NACLs require explicit rules for both request and return (ephemeral) traffic.
# =============================================================================

# -----------------------------------------------------------------------------
# Public Subnet NACL
# -----------------------------------------------------------------------------
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id

  # Ingress: Allow HTTP (Port 80)
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Ingress: Allow HTTPS (Port 443)
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Ingress: Allow Return Traffic on Ephemeral Ports (1024-65535)
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Egress: Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-public-nacl"
    }
  )
}

# -----------------------------------------------------------------------------
# Private Subnet NACL
# -----------------------------------------------------------------------------
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  # Ingress: Allow all intra-VPC communication
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Ingress: Allow Ephemeral Return Traffic from the Internet (via NAT Gateway)
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Egress: Allow all outbound traffic (to VPC and to internet via NAT GW)
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-private-nacl"
    }
  )
}
