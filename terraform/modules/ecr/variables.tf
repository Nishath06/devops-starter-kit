# =============================================================================
# modules/ecr/variables.tf — ECR Module Variables
# =============================================================================

variable "repository_names" {
  description = "List of ECR repository names to create for microservices."
  type        = list(string)
  default     = ["backend", "frontend", "ai-model", "worker"]
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repositories (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository."
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of tagged images to retain per repository."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags to merge into all ECR repositories."
  type        = map(string)
  default     = {}
}
