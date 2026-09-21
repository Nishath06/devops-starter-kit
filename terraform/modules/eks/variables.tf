# =============================================================================
# modules/eks/variables.tf — EKS Module Variables
# =============================================================================

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI Driver Pod Identity."
  type        = string
}

variable "ebs_csi_role_dependency" {
  type = any
}
variable "node_role_arn" {
  description = "IAM role ARN for worker nodes"
  type        = string
}

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
  description = "List of desired control plane logging types."
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
  description = "KMS Key ARN used for EKS envelope encryption of Kubernetes Secrets."
  type        = string
  default     = ""
}

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
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group (ON_DEMAND or SPOT)."
  type        = string
  default     = "ON_DEMAND"
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
    min_size     = 1
    max_size     = 3
  }
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels for the node group."
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "List of objects defining Kubernetes taints for the node group."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "secrets_store_csi_version" {
  type    = string
  default = "v1.4.8-eksbuild.1"
}
