# =============================================================================
# modules/secrets/variables.tf
# =============================================================================

variable "cluster_name" {
  description = "EKS Cluster name."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}

variable "mongodb_uri" {
  description = "MongoDB Atlas connection string."
  type        = string
  sensitive   = true
}
