#!/usr/bin/env bash
# =============================================================================
# scripts/apply.sh — Plan, Apply, and Configure kubectl
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"

# ANSI Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=====================================================${NC}"
echo -e "${CYAN}🏗️ Deploying Production EKS Infrastructure           ${NC}"
echo -e "${CYAN}=====================================================${NC}"

cd "${TERRAFORM_DIR}"

AUTO_APPROVE=false
if [[ "${1:-}" == "--auto-approve" ]]; then
  AUTO_APPROVE=true
fi

# Ensure terraform.tfvars exists
if [[ ! -f "terraform.tfvars" ]]; then
  if [[ -f "terraform.tfvars.example" ]]; then
    echo -e "${YELLOW}⚠️ Notice: terraform.tfvars not found. Copying from terraform.tfvars.example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
  else
    echo -e "${RED}❌ Error: Neither terraform.tfvars nor terraform.tfvars.example exists.${NC}"
    exit 1
  fi
fi

# 1. Terraform Plan
echo -e "\n${YELLOW}[1/3] Generating Terraform execution plan...${NC}"
terraform plan -out=tfplan

if [[ "$AUTO_APPROVE" != "true" ]]; then
  echo -e "\n${CYAN}Review the above plan carefully.${NC}"
  read -rp "Do you want to apply this plan? (yes/no): " CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${YELLOW}Deployment cancelled by user.${NC}"
    rm -f tfplan
    exit 0
  fi
fi

# 2. Terraform Apply
echo -e "\n${YELLOW}[2/3] Applying Terraform execution plan...${NC}"
terraform apply tfplan
rm -f tfplan
echo -e "${GREEN}✓ Infrastructure applied successfully!${NC}"

# 3. Update Kubeconfig
echo -e "\n${YELLOW}[3/3] Configuring kubectl context...${NC}"
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "ap-south-1")


aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"
echo -e "${GREEN}✓ Kubeconfig updated for cluster: ${CLUSTER_NAME}${NC}"

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}🎉 Deployment complete! Next: ./scripts/verify.sh    ${NC}"
echo -e "${GREEN}=====================================================${NC}"
