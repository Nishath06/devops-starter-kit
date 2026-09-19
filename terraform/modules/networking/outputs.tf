# =============================================================================
# modules/networking/outputs.tf — Networking Module Outputs
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables."
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ips" {
  description = "List of public Elastic IP addresses of the NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}
