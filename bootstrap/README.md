# 🚀 Bootstrap Layer (`bootstrap/`)

> **Day-0 Platform Installer for Kubernetes Clusters**  
> Installs and configures foundational Kubernetes operators, GitOps controllers, observability agents, and CSI storage drivers using Helm 3.

---

## 📋 Directory Contents

```text
bootstrap/
├── install.sh                  # One-command idempotent installer script
├── uninstall.sh                # Clean teardown script for all installed releases
├── kind-config.yaml            # KinD local cluster configuration (Port 80/443 mappings)
└── values/                     # Helm values override files per component
    ├── argocd.yaml             # ArgoCD server, repo-server, and Redis configuration
    ├── prometheus.yaml         # Prometheus Operator & scrape configurations
    ├── grafana.yaml            # Grafana admin credentials, datasources & persistence
    ├── aws-load-balancer.yaml   # AWS Load Balancer Controller settings
    ├── metrics-server.yaml     # Metrics Server flags (insecure TLS for local/dev)
    ├── external-secrets.yaml   # External Secrets Operator deployment settings
    ├── ebs-csi.yaml            # AWS EBS CSI Driver controller & node daemonset
    └── efs-csi.yaml            # AWS EFS CSI Driver daemonset
```

---

## ⚙️ What Gets Installed?

| Release Name | Helm Chart | Namespace | Purpose |
|---|---|---|---|
| `argocd` | `argo/argo-cd` | `argocd` | Declarative GitOps deployment engine |
| `kube-prometheus-stack` | `prometheus-community/kube-prometheus-stack` | `monitoring` | Prometheus, Alertmanager, Node Exporter & Grafana |
| `metrics-server` | `metrics-server/metrics-server` | `kube-system` | In-memory CPU/memory metrics required by HPA |
| `aws-load-balancer-controller` | `eks/aws-load-balancer-controller` | `kube-system` | Provisions AWS ALBs and NLBs dynamically |
| `external-secrets` | `external-secrets/external-secrets` | `external-secrets` | Syncs secrets from AWS Secrets Manager |
| `aws-ebs-csi-driver` | `aws-ebs-csi-driver/aws-ebs-csi-driver` | `kube-system` | Dynamically provisions Amazon EBS volumes |
| `aws-efs-csi-driver` | `aws-efs-csi-driver/aws-efs-csi-driver` | `kube-system` | Mounts Amazon EFS shared file systems |

---

## 🛠 How to Customize

1. **Change Grafana Admin Password**:
   Edit [`bootstrap/values/grafana.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/bootstrap/values/grafana.yaml) or pass `--set grafana.adminPassword="your-new-password"`.
2. **Configure AWS IAM Roles (IRSA)**:
   For EKS, export your IAM Role ARNs before installing:
   ```bash
   export LBC_IAM_ROLE_ARN="arn:aws:iam::<ACCOUNT_ID>:role/aws-load-balancer-controller"
   export EBS_CSI_IAM_ROLE_ARN="arn:aws:iam::<ACCOUNT_ID>:role/ebs-csi-controller-sa"
   ```
3. **Disable EFS CSI Driver**:
   If your application does not require shared EFS file systems, run:
   ```bash
   export EFS_ENABLED="false"
   ```

---

## 🧪 Testing on Local KinD Cluster

KinD is ideal for fast, zero-cost local validation without AWS dependencies:

```bash
# 1. Create a KinD cluster with ingress port mappings (if not already created):
kind create cluster --name bnp-cluster --config bootstrap/kind-config.yaml

# 2. Switch context:
kubectl config use-context kind-bnp-cluster

# 3. Install core platform operators (ArgoCD + Prometheus + Grafana + Metrics Server):
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install ArgoCD:
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  -f bootstrap/values/argocd.yaml

# Install Prometheus & Grafana:
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f bootstrap/values/prometheus.yaml \
  --set grafana.adminPassword="admin"

# Install Metrics Server (with KinD insecure kubelet TLS flag enabled):
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  -f bootstrap/values/metrics-server.yaml \
  --set args="{--kubelet-insecure-tls}"
```

---

## 🧪 Testing on Amazon EKS

On a live EKS cluster, run the all-in-one idempotent installer:

```bash
# 1. Update kubeconfig for your EKS cluster:
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>

# 2. Verify connection:
kubectl get nodes

# 3. Dry-run to preview commands:
./bootstrap/install.sh --dry-run

# 4. Execute full installation:
export CLUSTER_NAME="<YOUR_EKS_CLUSTER>"
export AWS_REGION="ap-south-1"
./bootstrap/install.sh
```

---

## 🔑 Accessing Dashboards Post-Install

### 1. ArgoCD Web UI
```bash
# Get admin password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Port-forward:
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080 (User: admin)
```

### 2. Grafana Dashboard
```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
# Visit: http://localhost:3000 (User: admin / Pass: admin)
```

---

## 🧹 Teardown

To cleanly remove all platform components:
```bash
./bootstrap/uninstall.sh
```
