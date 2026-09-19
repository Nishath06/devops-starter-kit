# =============================================================================
# modules/networking/variables.tf — Networking Module Variables
# =============================================================================

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets (minimum 2)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets (minimum 2)."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster for Kubernetes discovery tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. prod, dev)."
  type        = string
  default     = "prod"
}

variable "single_nat_gateway" {
  description = "If true, provision only one NAT Gateway. If false, provision one per AZ."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch for network auditing."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to merge into all resources."
  type        = map(string)
  default     = {}
}
