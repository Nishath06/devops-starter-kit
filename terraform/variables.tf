# =============================================================================
# variables.tf — Root Terraform Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Global / Environment Variables
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "The aws_region must follow the standard AWS region naming convention (e.g., ap-south-1, us-east-1)."
  }
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Allowed values for environment are: dev, staging, prod, test."
  }
}

variable "project_name" {
  description = "Project name prefix used for identifying and grouping resources."
  type        = string
  default     = "devops-starter-kit"
}

variable "cluster_name" {
  description = "The name of the Amazon EKS cluster."
  type        = string
  default     = "production-eks-cluster"

  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9-_]{1,99}$", var.cluster_name))
    error_message = "The cluster_name must be between 1 and 100 characters and contain only alphanumeric characters, dashes, and underscores."
  }
}

variable "cluster_version" {
  description = "Kubernetes control plane version for the EKS cluster."
  type        = string
  default     = "1.33"
}

# -----------------------------------------------------------------------------
# Networking Variables
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "The CIDR block for the Virtual Private Cloud (VPC)."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR address block."
  }
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets (minimum 2 across separate AZs)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "At least two public subnets in distinct Availability Zones are required for high availability."
  }
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets (minimum 2 across separate AZs)."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]

  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "At least two private subnets in distinct Availability Zones are required for high availability."
  }
}

variable "single_nat_gateway" {
  description = "Set to true to deploy only 1 NAT Gateway for cost savings (non-prod), or false for 1 NAT Gateway per AZ (production HA)."
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs for security analysis and network monitoring."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# EKS Cluster Control Plane Variables
# -----------------------------------------------------------------------------
variable "cluster_endpoint_public_access" {
  description = "Indicates whether the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that are allowed access to the public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "List of desired control plane logging types (api, audit, authenticator, controllerManager, scheduler)."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_in_days" {
  description = "Retention period in days for CloudWatch log group storing EKS control plane logs."
  type        = number
  default     = 30
}

variable "enable_encryption" {
  description = "Enable envelope encryption of Kubernetes Secrets at rest using AWS KMS."
  type        = bool
  default     = false
}

variable "encryption_key_arn" {
  description = "KMS Key ARN used for EKS envelope encryption of Kubernetes Secrets (if enable_encryption is true)."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# EKS Managed Node Group Variables
# -----------------------------------------------------------------------------
variable "node_group_name" {
  description = "Name identifier for the managed worker node group."
  type        = string
  default     = "general-workers"
}

variable "node_instance_types" {
  description = "List of EC2 instance types for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group (e.g., AL2023_x86_64_STANDARD)."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group (ON_DEMAND or SPOT)."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Allowed capacity types are ON_DEMAND or SPOT."
  }
}

variable "node_disk_size" {
  description = "Root EBS disk size in GiB for each worker node instance."
  type        = number
  default     = 50
}

variable "node_scaling_config" {
  description = "Scaling configuration defining desired, min, and max worker node capacity."
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = {
    desired_size = 2
    min_size     = 2
    max_size     = 5
  }
}

variable "node_labels" {
  description = "Kubernetes labels to apply to all nodes in the managed node group."
  type        = map(string)
  default = {
    role        = "worker"
    environment = "prod"
  }
}

variable "node_taints" {
  description = "Kubernetes taints to apply to the node group for workload isolation."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# ECR Variables
# -----------------------------------------------------------------------------
variable "ecr_repositories" {
  description = "List of Amazon ECR repository names to create for container images."
  type        = list(string)
  default     = ["backend", "frontend", "ai-model", "worker"]
}

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for ECR repositories (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "The ecr_image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "ecr_scan_on_push" {
  description = "Enable vulnerability scanning on image push."
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Number of tagged images to retain per repository before lifecycle expiration."
  type        = number
  default     = 10
}

# -----------------------------------------------------------------------------
# Tagging Variables
# -----------------------------------------------------------------------------
variable "tags" {
  description = "Additional tags to merge into all resources."
  type        = map(string)
  default     = {}
}

variable "microservices" {
  description = "Microservices deployed in this project"

  type = map(object({
    repository = string
    namespace  = string
    port       = number
  }))

  default = {}
}
