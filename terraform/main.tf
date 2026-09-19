# =============================================================================
# main.tf — Root Terraform Module Orchestration
# =============================================================================
# Orchestrates all modules in accordance with AWS Well-Architected Framework:
#   1. networking: Multi-AZ VPC, Public/Private Subnets, NAT Gateways, Route Tables, NACLs
#   2. iam: Cluster and Worker Node IAM roles with least-privilege policies and OIDC provider
#   3. eks: EKS Control Plane v1.33, Managed Node Groups, Security Groups, Addons, Logging
#   4. ecr: Microservice Container Repositories with Lifecycle Policies & Vulnerability Scanning
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Networking Module (VPC, Subnets, Gateways, Route Tables, NACLs)
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  cluster_name       = var.cluster_name
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_vpc_flow_logs

  tags = var.tags
}

# -----------------------------------------------------------------------------
# 2. IAM Module (Cluster Role, Node Role, Policy Attachments, OIDC Provider)
# -----------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  cluster_name    = var.cluster_name
  oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  tags = var.tags
}

# -----------------------------------------------------------------------------
# 3. EKS Module (Control Plane, Node Group, Security Groups, Addons, Logging)
# -----------------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.private_subnets
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_log_types             = var.cluster_log_types
  cluster_log_retention_in_days = var.cluster_log_retention_in_days

  enable_encryption       = var.enable_encryption
  encryption_key_arn      = var.encryption_key_arn
  ebs_csi_role_arn        = module.iam.ebs_csi_role_arn
  ebs_csi_role_dependency = module.iam.ebs_csi_role_dependency

  node_group_name     = var.node_group_name
  node_instance_types = var.node_instance_types
  node_ami_type       = var.node_ami_type
  node_capacity_type  = var.node_capacity_type
  node_disk_size      = var.node_disk_size
  node_scaling_config = var.node_scaling_config
  node_labels         = var.node_labels
  node_taints         = var.node_taints

  tags = var.tags
}

# -----------------------------------------------------------------------------
# 4. ECR Module (Repositories & Lifecycle Policies)
# -----------------------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  repository_names     = var.ecr_repositories
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  max_image_count      = var.ecr_max_image_count

  tags = var.tags
}
