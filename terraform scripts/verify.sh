#!/usr/bin/env bash
# =============================================================================
# scripts/verify.sh — Verify Cluster Health and Operational Status
# =============================================================================
set -euo pipefail

# ANSI Color Codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=====================================================${NC}"
echo -e "${CYAN}🔍 Verifying EKS Cluster Health & Connectivity       ${NC}"
echo -e "${CYAN}=====================================================${NC}"

# Check for kubectl
if ! command -v kubectl &>/dev/null; then
  echo -e "${RED}❌ Error: 'kubectl' command not found. Please install kubectl.${NC}"
  exit 1
fi

TOTAL_CHECKS=5
PASSED_CHECKS=0

run_check() {
  local title="$1"
  local cmd="$2"

  echo -e "\n${YELLOW}Running Check: ${title}${NC}"
  if eval "$cmd"; then
    echo -e "${GREEN}✓ Check Passed: ${title}${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
  else
    echo -e "${RED}✗ Check Failed: ${title}${NC}"
  fi
}

# 1. Kubernetes API Cluster Info
run_check "Kubernetes Control Plane API Info" "kubectl cluster-info"

# 2. Worker Nodes Status
run_check "Worker Nodes Readiness" "kubectl get nodes -o wide"

# 3. Kube-System Pods Status
run_check "System Pods in kube-system Namespace" "kubectl get pods -n kube-system"

# 4. Core Services Status
run_check "Cluster Services Status" "kubectl get svc -A"

# 5. CoreDNS and CNI Rollout Status
run_check "CoreDNS Rollout Health" "kubectl rollout status deployment/coredns -n kube-system --timeout=60s"

echo -e "\n${CYAN}=====================================================${NC}"
if [[ $PASSED_CHECKS -eq $TOTAL_CHECKS ]]; then
  echo -e "${GREEN}✅ All ${TOTAL_CHECKS}/${TOTAL_CHECKS} health checks PASSED! Cluster is operational.${NC}"
else
  echo -e "${YELLOW}⚠️ ${PASSED_CHECKS}/${TOTAL_CHECKS} health checks passed. Please review any failed checks above.${NC}"
fi
echo -e "${CYAN}=====================================================${NC}"
