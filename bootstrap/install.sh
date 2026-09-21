#!/usr/bin/env bash
# ==============================================================================
# bootstrap/install.sh
# ------------------------------------------------------------------------------
# Purpose : Idempotent installation of all platform components on Amazon EKS.
# Usage   : bash bootstrap/install.sh [--dry-run]
# Author  : Platform Engineering Team
# Version : 1.0.0
#
# Components installed (via Helm):
#   1. ArgoCD
#   2. kube-prometheus-stack  (Prometheus + Grafana + Alertmanager)
#   3. Metrics Server
#   4. AWS Load Balancer Controller
#   5. External Secrets Operator
#   6. AWS EBS CSI Driver
#   7. AWS EFS CSI Driver  (optional — skipped if EFS_ENABLED=false)
#
# Prerequisites:
#   - kubectl configured and pointing at your EKS cluster
#   - helm v3.x installed
#   - AWS CLI configured (for cluster context)
#   - Cluster already provisioned (Terraform handles infra)
#
# Environment variables (all optional, sane defaults provided):
#   CLUSTER_NAME       - EKS cluster name (used in --set flags)
#   AWS_REGION         - AWS region (default: us-east-1)
#   EFS_ENABLED        - Install EFS CSI driver? (default: true)
#   ARGOCD_VERSION     - Helm chart version for ArgoCD
#   DRY_RUN            - Set to "true" to print commands without executing
# ==============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Load environment variables from bootstrap/.env
# ---------------------------------------------------------------------------
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"

if [[ -f "${ENV_FILE}" ]]; then
  echo "[INFO] Loading configuration from ${ENV_FILE}"
  set -a
  source "${ENV_FILE}"
  set +a
else
  echo "[WARN] No bootstrap/.env found. Falling back to default environment variables."
fi
# ---------------------------------------------------------------------------
# Colour helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
# Configuration (override via env vars)
# ---------------------------------------------------------------------------
CLUSTER_NAME="${CLUSTER_NAME:-my-eks-cluster}"
AWS_REGION="${AWS_REGION:-us-east-1}"
EFS_ENABLED="${EFS_ENABLED:-true}"
DRY_RUN="${DRY_RUN:-false}"

# Helm chart versions — pin these for reproducibility in production
ARGOCD_CHART_VERSION="${ARGOCD_CHART_VERSION:-7.4.4}"
PROMETHEUS_CHART_VERSION="${PROMETHEUS_CHART_VERSION:-62.3.1}"
METRICS_SERVER_CHART_VERSION="${METRICS_SERVER_CHART_VERSION:-3.12.1}"
AWS_LBC_CHART_VERSION="${AWS_LBC_CHART_VERSION:-1.8.1}"
EXTERNAL_SECRETS_CHART_VERSION="${EXTERNAL_SECRETS_CHART_VERSION:-0.10.0}"
EBS_CSI_CHART_VERSION="${EBS_CSI_CHART_VERSION:-2.33.0}"
EFS_CSI_CHART_VERSION="${EFS_CSI_CHART_VERSION:-3.0.7}"
SECRETS_STORE_CSI_CHART_VERSION="${SECRETS_STORE_CSI_CHART_VERSION:-1.4.7}"
AWS_PROVIDER_CHART_VERSION="${AWS_PROVIDER_CHART_VERSION:-0.3.9}"
# Script directory — all values files are relative to here
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_DIR="${SCRIPT_DIR}/values"

# Secrets Store CSI Driver IRSA Role
SECRETS_CSI_IAM_ROLE_ARN="${SECRETS_CSI_IAM_ROLE_ARN:-}"

# External Secrets Operator IRSA Role
ESO_IAM_ROLE_ARN="${ESO_IAM_ROLE_ARN:-}"
# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
run() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo -e "${YELLOW}[DRY-RUN]${NC} $*"
  else
    eval "$@"
  fi
}

# Idempotent namespace creation
ensure_namespace() {
  local ns="$1"
  if kubectl get namespace "${ns}" &>/dev/null; then
    info "Namespace '${ns}' already exists — skipping."
  else
    info "Creating namespace '${ns}'..."
    run kubectl create namespace "${ns}"
    success "Namespace '${ns}' created."
  fi
}

# Idempotent Helm repo registration
add_helm_repo() {
  local name="$1" url="$2"
  if helm repo list 2>/dev/null | grep -q "^${name}"; then
    info "Helm repo '${name}' already registered — skipping."
  else
    info "Adding Helm repo '${name}'..."
    run helm repo add "${name}" "${url}"
  fi
}

# Idempotent Helm install / upgrade
helm_upgrade_install() {
  local release="$1" chart="$2" namespace="$3" values_file="$4"
  shift 4
  local extra_args=("$@")

  if helm status "${release}" -n "${namespace}" &>/dev/null; then
    info "Release '${release}' already installed — upgrading..."
    run helm upgrade "${release}" "${chart}" \
      --namespace "${namespace}" \
      --values "${values_file}" \
      --wait \
      --timeout 10m \
      "${extra_args[@]+"${extra_args[@]}"}"
  else
    info "Installing '${release}'..."
    run helm install "${release}" "${chart}" \
      --namespace "${namespace}" \
      --create-namespace \
      --values "${values_file}" \
      --wait \
      --timeout 10m \
      "${extra_args[@]+"${extra_args[@]}"}"
  fi
  success "'${release}' is ready."
}

require_env() {
  local var="$1"

  if [[ -z "${!var:-}" ]]; then
    error "Environment variable '$var' is required."
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
preflight() {
  info "Running pre-flight checks..."
  for cmd in kubectl helm aws; do
    if ! command -v "${cmd}" &>/dev/null; then
      error "Required tool '${cmd}' is not installed or not in PATH."
      exit 1
    fi
  done

  if ! kubectl cluster-info &>/dev/null; then
    error "kubectl cannot reach the cluster. Check your kubeconfig."
    exit 1
  fi

  success "Pre-flight checks passed."
}

# ---------------------------------------------------------------------------
# Step 0: Add Helm repositories
# ---------------------------------------------------------------------------
setup_helm_repos() {
  info "Setting up Helm repositories..."
  add_helm_repo "argo"            "https://argoproj.github.io/argo-helm"
  add_helm_repo "prometheus"      "https://prometheus-community.github.io/helm-charts"
  add_helm_repo "metrics-server"  "https://kubernetes-sigs.github.io/metrics-server/"
  add_helm_repo "eks"             "https://aws.github.io/eks-charts"
  add_helm_repo "external-secrets" "https://charts.external-secrets.io"
  add_helm_repo "aws-ebs-csi"     "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  add_helm_repo "aws-efs-csi"     "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  add_helm_repo "secrets-store-csi-driver" "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  add_helm_repo "aws-secrets-manager" "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  run helm repo update
  success "Helm repositories updated."
}

# ---------------------------------------------------------------------------
# Step 1: ArgoCD
# ---------------------------------------------------------------------------
install_argocd() {
  info "==> Installing ArgoCD..."
  ensure_namespace "argocd"
  helm_upgrade_install \
    "argocd" \
    "argo/argo-cd" \
    "argocd" \
    "${VALUES_DIR}/argocd.yaml" \
    --version "${ARGOCD_CHART_VERSION}"
}

# ---------------------------------------------------------------------------
# Step 2: kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
# ---------------------------------------------------------------------------
install_prometheus_stack() {
  info "==> Installing kube-prometheus-stack..."
  ensure_namespace "monitoring"
  helm_upgrade_install \
    "kube-prometheus-stack" \
    "prometheus/kube-prometheus-stack" \
    "monitoring" \
    "${VALUES_DIR}/prometheus.yaml" \
    --version "${PROMETHEUS_CHART_VERSION}" \
    --set grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD:-"prom-operator"}"
}

# ---------------------------------------------------------------------------
# Step 3: Metrics Server
# ---------------------------------------------------------------------------
install_metrics_server() {
  info "==> Installing Metrics Server..."
  ensure_namespace "kube-system"
  helm_upgrade_install \
    "metrics-server" \
    "metrics-server/metrics-server" \
    "kube-system" \
    "${VALUES_DIR}/metrics-server.yaml" \
    --version "${METRICS_SERVER_CHART_VERSION}"
}

# ---------------------------------------------------------------------------
# Step 4: AWS Load Balancer Controller
# ---------------------------------------------------------------------------
install_aws_lbc() {
  info "==> Installing AWS Load Balancer Controller..."
  # NOTE: The LBC requires an IAM role attached to the ServiceAccount.
  # The role ARN must be set via: --set serviceAccount.annotations."eks.amazonaws.com/role-arn"=<ROLE_ARN>
  # Create the IAM role and policy separately (Terraform) and export LBC_IAM_ROLE_ARN.
  local lbc_role_arn="${LBC_IAM_ROLE_ARN:-arn:aws:iam::ACCOUNT_ID:role/aws-load-balancer-controller}"

  ensure_namespace "kube-system"
  helm_upgrade_install \
    "aws-load-balancer-controller" \
    "eks/aws-load-balancer-controller" \
    "kube-system" \
    "${VALUES_DIR}/aws-load-balancer.yaml" \
    --version "${AWS_LBC_CHART_VERSION}" \
    --set "clusterName=${CLUSTER_NAME}" \
    --set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${lbc_role_arn}"
}

# ---------------------------------------------------------------------------
# Step 5: External Secrets Operator
# ---------------------------------------------------------------------------
install_external_secrets() {
  info "==> Installing External Secrets Operator..."

  require_env ESO_IAM_ROLE_ARN

  ensure_namespace "external-secrets"

  helm_upgrade_install \
    "external-secrets" \
    "external-secrets/external-secrets" \
    "external-secrets" \
    "${VALUES_DIR}/external-secrets.yaml" \
    --version "${EXTERNAL_SECRETS_CHART_VERSION}" \
    --set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${ESO_IAM_ROLE_ARN}"

  success "External Secrets Operator installed."
}
# ---------------------------------------------------------------------------
# Step 6: AWS EBS CSI Driver
# ---------------------------------------------------------------------------
install_ebs_csi() {
  info "==> Installing AWS EBS CSI Driver..."
  # NOTE: Requires IAM role for EBS operations.
  # Export EBS_CSI_IAM_ROLE_ARN before running this script.
  local ebs_role_arn="${EBS_CSI_IAM_ROLE_ARN:-arn:aws:iam::ACCOUNT_ID:role/ebs-csi-controller-sa}"

  ensure_namespace "kube-system"
  helm_upgrade_install \
    "aws-ebs-csi-driver" \
    "aws-ebs-csi/aws-ebs-csi-driver" \
    "kube-system" \
    "${VALUES_DIR}/ebs-csi.yaml" \
    --version "${EBS_CSI_CHART_VERSION}" \
    --set "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${ebs_role_arn}"
}

# ---------------------------------------------------------------------------
# Step 7: AWS EFS CSI Driver (optional)
# ---------------------------------------------------------------------------
install_efs_csi() {
  if [[ "${EFS_ENABLED}" != "true" ]]; then
    warn "EFS_ENABLED is not 'true' — skipping EFS CSI Driver installation."
    return
  fi
  info "==> Installing AWS EFS CSI Driver..."
  # NOTE: Requires IAM role for EFS operations.
  # Export EFS_CSI_IAM_ROLE_ARN before running this script.
  local efs_role_arn="${EFS_CSI_IAM_ROLE_ARN:-arn:aws:iam::ACCOUNT_ID:role/efs-csi-controller-sa}"

  ensure_namespace "kube-system"
  helm_upgrade_install \
    "aws-efs-csi-driver" \
    "aws-efs-csi/aws-efs-csi-driver" \
    "kube-system" \
    "${VALUES_DIR}/efs-csi.yaml" \
    --version "${EFS_CSI_CHART_VERSION}" \
    --set "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${efs_role_arn}"
}

install_secrets_store_csi() {
  info "==> Installing Secrets Store CSI Driver..."

  require_env SECRETS_CSI_IAM_ROLE_ARN

  ensure_namespace "kube-system"

  # Install Secrets Store CSI Driver
  helm_upgrade_install \
    "secrets-store-csi-driver" \
    "secrets-store-csi-driver/secrets-store-csi-driver" \
    "kube-system" \
    "${VALUES_DIR}/secrets-store-csi.yaml" \
    --version "${SECRETS_STORE_CSI_CHART_VERSION}"

  # Install AWS Provider for Secrets Store CSI Driver
  helm_upgrade_install \
    "secrets-provider-aws" \
    "aws-secrets-manager/secrets-provider-aws" \
    "kube-system" \
    "${VALUES_DIR}/secrets-provider-aws.yaml" \
    --version "${AWS_PROVIDER_CHART_VERSION}" \
    --set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${SECRETS_CSI_IAM_ROLE_ARN}"

  # Wait until DaemonSet is ready
  kubectl rollout status daemonset/csi-secrets-store \
    -n kube-system --timeout=5m

  success "Secrets Store CSI Driver installed."
}

# ---------------------------------------------------------------------------
# Step 8: Apply platform namespaces and base resources
# ---------------------------------------------------------------------------
apply_platform_base() {
  info "==> Applying platform base manifests..."
  local repo_root
  repo_root="$(cd "${SCRIPT_DIR}/.." && pwd)"

  run kubectl apply -f "${repo_root}/platform/namespaces/" --recursive
  success "Platform namespaces applied."
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print_summary() {
  echo ""
  echo -e "${GREEN}============================================================${NC}"
  echo -e "${GREEN}  Bootstrap complete!${NC}"
  echo -e "${GREEN}============================================================${NC}"
  echo ""
  echo "  Next steps:"
  echo "  1. Get ArgoCD initial admin password:"
  echo "     kubectl -n argocd get secret argocd-initial-admin-secret \\"
  echo "       -o jsonpath='{.data.password}' | base64 -d"
  echo ""
  echo "  2. Port-forward ArgoCD UI:"
  echo "     kubectl port-forward svc/argocd-server -n argocd 8080:443"
  echo ""
  echo "  3. Apply the root ArgoCD application:"
  echo "     kubectl apply -f argocd/root-application.yaml"
  echo ""
  echo "  4. Apply the AppProject:"
  echo "     kubectl apply -f argocd/app-project.yaml"
  echo ""
  echo "  5. Configure your Git repository URL in argocd/root-application.yaml"
  echo ""
  echo -e "${CYAN}  Grafana:${NC} kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80"
  echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo ""
  echo -e "${CYAN}==============================================================${NC}"
  echo -e "${CYAN}  K8s GitOps Starter Platform — Bootstrap Installer v1.0.0  ${NC}"
  echo -e "${CYAN}==============================================================${NC}"
  echo ""

  if [[ "${1:-}" == "--dry-run" ]]; then
    export DRY_RUN="true"
    warn "DRY-RUN mode enabled — no changes will be applied."
  fi

  preflight
  setup_helm_repos
  install_argocd
  install_prometheus_stack
  install_metrics_server
  install_aws_lbc
  install_external_secrets
  install_ebs_csi
  install_efs_csi
  apply_platform_base
  print_summary
}

main "$@"
