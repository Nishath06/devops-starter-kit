# =============================================================================
# providers.tf — Provider Configurations
# =============================================================================
# Configures the AWS, Kubernetes, Helm, and TLS providers.
# Uses the official AWS recommended `exec` plugin (`aws eks get-token`) for
# Kubernetes and Helm providers to prevent plan-time lookup errors on fresh clusters
# and avoid 15-minute token expiration issues during long applies.
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Owner       = "DevOps-Team"
        Repository  = "devops-starter-kit"
      },
      var.tags
    )
  }
}

provider "tls" {}

# -----------------------------------------------------------------------------
# Dynamic Authentication for Kubernetes & Helm Providers via AWS CLI Exec
# -----------------------------------------------------------------------------
# Official AWS Recommended Pattern:
# Instead of `data.aws_eks_cluster_auth` (which expires in 15 mins and fails plan
# before the cluster exists), `exec` fetches a fresh token on-demand using AWS CLI.
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}
