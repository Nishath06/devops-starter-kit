#!/usr/bin/env bash
# =============================================================================
# scripts/init.sh — Initialize and Validate Terraform Configuration
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"

# ANSI Color Codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================================${NC}"
echo -e "${CYAN}🚀 Initializing EKS DevOps Starter Kit Terraform     ${NC}"
echo -e "${CYAN}=====================================================${NC}"

# Check Prerequisites
for cmd in terraform aws; do
  if ! command -v "$cmd" &>/dev/null; then
    echo -e "${RED}❌ Error: '$cmd' command not found. Please install it first.${NC}"
    exit 1
  fi
done

cd "${TERRAFORM_DIR}"

# 1. Format Code
echo -e "\n${YELLOW}[1/3] Formatting Terraform files...${NC}"
terraform fmt -recursive
echo -e "${GREEN}✓ Formatting complete.${NC}"

# 2. Initialize Working Directory
echo -e "\n${YELLOW}[2/3] Initializing Terraform working directory and providers...${NC}"
terraform init
echo -e "${GREEN}✓ Initialization complete.${NC}"

# 3. Validate Configuration
echo -e "\n${YELLOW}[3/3] Validating Terraform syntax and modules...${NC}"
terraform validate
echo -e "${GREEN}✓ Validation passed successfully!${NC}"

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}✨ Ready to deploy! Next step: ./scripts/apply.sh   ${NC}"
echo -e "${GREEN}=====================================================${NC}"
