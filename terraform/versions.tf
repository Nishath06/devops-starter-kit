# =============================================================================
# versions.tf — Required Terraform Version and Provider Constraints
# =============================================================================
# Production EKS DevOps Starter Kit
# =============================================================================

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.58.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote State Backend (S3 + DynamoDB State Locking)
  # ---------------------------------------------------------------------------
  # Uncomment and configure this block before deploying in team/CI-CD environments.
  # Best Practice: S3 versioning enabled, server-side encryption (KMS/AES256),
  # and DynamoDB table with LockID (String) attribute for distributed locking.
  #
  # backend "s3" {
  #   bucket         = "my-company-terraform-state-eks-prod"
  #   key            = "eks/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-state-lock-eks-prod"
  #   encrypt        = true
  # }
}
