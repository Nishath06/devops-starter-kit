#!/usr/bin/env bash
# =============================================================================
# scripts/destroy.sh — Safely Teardown EKS Infrastructure
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"

# ANSI Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}=====================================================${NC}"
echo -e "${RED}⚠️  DANGER ZONE: INFRASTRUCTURE DESTROY               ${NC}"
echo -e "${RED}=====================================================${NC}"

cd "${TERRAFORM_DIR}"

# 1. Fetch cluster name if available
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "eks-cluster")

echo -e "${YELLOW}You are about to destroy ALL resources associated with cluster: ${CLUSTER_NAME}${NC}"
echo -e "${YELLOW}This includes VPC, Subnets, NAT Gateways, EKS Cluster, Node Groups, and ECR Repositories.${NC}"
read -rp "Are you absolutely sure? Type 'destroy-infrastructure' to confirm: " CONFIRM

if [[ "$CONFIRM" != "destroy-infrastructure" ]]; then
  echo -e "${GREEN}Destruction aborted safely.${NC}"
  exit 0
fi

# 2. Cleanup Kubernetes resources that create AWS infrastructure (like LoadBalancers / PVCs)
if command -v kubectl &>/dev/null; then
  echo -e "\n${YELLOW}Checking for active LoadBalancer services and PVCs that might block VPC deletion...${NC}"
  kubectl delete svc --all --all-namespaces --field-selector spec.type=LoadBalancer --timeout=90s 2>/dev/null || true
fi

# 3. Terraform Destroy
echo -e "\n${RED}Initiating Terraform destroy...${NC}"
terraform destroy -auto-approve

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}✓ All infrastructure has been completely destroyed.  ${NC}"
echo -e "${GREEN}=====================================================${NC}"
