# =============================================================================
# modules/iam/variables.tf — IAM Module Variables
# =============================================================================

variable "cluster_name" {
  description = "The name of the Amazon EKS cluster."
  type        = string
}

variable "oidc_issuer_url" {
  description = "The OIDC issuer URL from the EKS cluster (https://oidc.eks.<region>.amazonaws.com/id/<id>)."
  type        = string
}

variable "tags" {
  description = "Additional tags to merge into all IAM resources."
  type        = map(string)
  default     = {}
}
