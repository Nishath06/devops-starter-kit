# 🌍 Environment Management (`environments/`)

> **Target-Specific Values Overrides for GitOps Deployments**  
> Decouples environment configurations (local laptop vs AWS dev vs production) and serves as the single point of change for automated CI/CD pipelines.

---

## 📋 Directory Contents

```text
environments/
├── local/                      # Local testing overrides (KinD / Minikube / Docker Desktop)
│   └── values.yaml             # 1 replica, standard local storage, NGINX ingress, low RAM/CPU
├── dev/                        # AWS Development environment
│   └── values.yaml             # 1 replica, internal ALB, debug logging
├── staging/                    # AWS Pre-production Staging environment
│   └── values.yaml             # 2 replicas, production-like testing, HPA enabled
└── prod/                       # AWS Production environment
    └── values.yaml             # HA replicas (3+), Multi-AZ anti-affinity, WAF, strict HPA
```

---

## 🔄 The GitOps CI/CD Mutation Workflow

In a production GitOps model, developers never modify YAML manifests manually in production. 

Instead, your application's GitHub Actions CI pipeline builds the Docker image, pushes it to Amazon ECR, and creates a Git commit in this repository updating **only one line**:

```yaml
# environments/prod/values.yaml
image:
  tag: "sha-9f8e7d6"   # ← Automated CI/CD updates ONLY this image tag
```

Once committed to Git, ArgoCD detects the change and triggers a zero-downtime rolling update.

---

## ⚙️ Environment Characteristics Matrix

| Feature | `local/` (KinD) | `dev/` (EKS) | `staging/` (EKS) | `prod/` (EKS) |
|---|---|---|---|---|
| **Replicas** | 1 | 1 | 2 | 3+ (HA) |
| **Ingress Type** | NGINX | Internal ALB | Internet ALB | Internet ALB + WAF |
| **StorageClass** | `standard` (local-path) | `ebs-gp3` | `ebs-gp3` | `ebs-gp3` (encrypted) |
| **Autoscaling (HPA)** | Disabled | Disabled | Enabled (2–5) | Enabled (3–15) |
| **PDB (Disruption)** | Disabled | Optional | Enabled | Strictly enforced |
| **Log Level** | `debug` | `debug` | `info` | `warn` / `info` |

---

## 🧪 Testing on Local KinD Cluster

```bash
# 1. Switch context:
kubectl config use-context kind-bnp-cluster

# 2. Deploy using local environment values:
helm upgrade --install demo-service helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/local/values.yaml \
  --namespace apps --create-namespace

# 3. Check pods:
kubectl get pods -n apps
```

---

## 🧪 Testing on Amazon EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>

# 1. Deploy Dev environment:
helm upgrade --install demo-dev helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/dev/values.yaml \
  --namespace apps-dev --create-namespace

# 2. Deploy Prod environment:
helm upgrade --install demo-prod helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/prod/values.yaml \
  --namespace apps-prod --create-namespace
```
