#!/usr/bin/env bash
# ==============================================================================
# bootstrap/uninstall.sh
# ------------------------------------------------------------------------------
# Purpose : Tear down all platform components installed by install.sh.
# Usage   : bash bootstrap/uninstall.sh [--dry-run]
#
# WARNING : This will remove ArgoCD, monitoring, and all CSI drivers.
#           All PersistentVolumes (EBS/EFS) will NOT be automatically deleted
#           unless the StorageClass reclaimPolicy is "Delete".
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }

DRY_RUN="${DRY_RUN:-false}"

run() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo -e "${YELLOW}[DRY-RUN]${NC} $*"
  else
    eval "$@" || true   # Allow failures during uninstall (release may not exist)
  fi
}

helm_uninstall() {
  local release="$1" namespace="$2"
  if helm status "${release}" -n "${namespace}" &>/dev/null; then
    info "Uninstalling '${release}' from namespace '${namespace}'..."
    run helm uninstall "${release}" --namespace "${namespace}" --wait
    success "'${release}' removed."
  else
    warn "Release '${release}' not found in '${namespace}' — skipping."
  fi
}

delete_namespace() {
  local ns="$1"
  if kubectl get namespace "${ns}" &>/dev/null; then
    info "Deleting namespace '${ns}'..."
    run kubectl delete namespace "${ns}" --timeout=120s
    success "Namespace '${ns}' deleted."
  else
    warn "Namespace '${ns}' not found — skipping."
  fi
}

main() {
  echo ""
  echo -e "${RED}============================================================${NC}"
  echo -e "${RED}  K8s GitOps Starter Platform — Uninstaller v1.0.0        ${NC}"
  echo -e "${RED}============================================================${NC}"
  echo ""

  if [[ "${1:-}" == "--dry-run" ]]; then
    export DRY_RUN="true"
    warn "DRY-RUN mode enabled — no changes will be applied."
  fi

  warn "This will remove all platform components. Press CTRL+C within 5s to abort..."
  sleep 5

  # Remove in reverse install order to respect dependencies
  helm_uninstall "aws-efs-csi-driver"             "kube-system"
  helm_uninstall "aws-ebs-csi-driver"             "kube-system"
  helm_uninstall "external-secrets"               "external-secrets"
  helm_uninstall "aws-load-balancer-controller"   "kube-system"
  helm_uninstall "metrics-server"                 "kube-system"
  helm_uninstall "kube-prometheus-stack"          "monitoring"
  helm_uninstall "argocd"                         "argocd"

  # Clean up CRDs left by kube-prometheus-stack (optional)
  warn "Removing Prometheus CRDs (if any remain)..."
  run kubectl delete crd \
    alertmanagerconfigs.monitoring.coreos.com \
    alertmanagers.monitoring.coreos.com \
    podmonitors.monitoring.coreos.com \
    probes.monitoring.coreos.com \
    prometheusagents.monitoring.coreos.com \
    prometheuses.monitoring.coreos.com \
    prometheusrules.monitoring.coreos.com \
    scrapeconfigs.monitoring.coreos.com \
    servicemonitors.monitoring.coreos.com \
    thanosrulers.monitoring.coreos.com \
    2>/dev/null || true

  delete_namespace "argocd"
  delete_namespace "monitoring"
  delete_namespace "external-secrets"

  # NOTE: We intentionally do NOT delete "kube-system" or app namespaces.
  # Delete those manually: kubectl delete namespace apps platform

  echo ""
  success "Platform uninstall complete."
  warn "Application namespaces (apps, platform, etc.) were NOT deleted."
  warn "PersistentVolumes (EBS/EFS) were NOT deleted — clean up manually via AWS console."
}

main "$@"
