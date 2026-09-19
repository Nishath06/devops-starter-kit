# 🐙 ArgoCD GitOps Engine (`argocd/`)

> **Declarative Continuous Delivery & GitOps Synchronization**  
> Manages the lifecycle of all platform components and application microservices following the industry-standard **App-of-Apps** pattern.

---

## 📋 Directory Contents

```text
argocd/
├── root-application.yaml       # Master App-of-Apps entry point (Watches argocd/applications/)
├── app-project.yaml            # RBAC and namespace security boundaries (AppProject)
├── applications/               # Individual Application definitions
│   ├── backend.yaml            # Syncs apps/backend/ into 'apps' namespace
│   ├── frontend.yaml           # Syncs apps/frontend/ into 'apps' namespace
│   ├── workers.yaml            # Syncs apps/worker/ into 'apps' namespace
│   ├── monitoring.yaml         # Syncs platform/monitoring/ into 'monitoring' namespace
│   └── networking.yaml         # Syncs platform/networking/ into 'platform' namespace
└── applicationsets/            # Multi-environment automation generator
    └── env-appset.yaml         # Automatically provisions dev, staging, and prod stacks
```

---

## 🏗 How It Works: The App-of-Apps Pattern

```
┌─────────────────────────────────────────────────────────┐
│                 root-application.yaml                   │
│             (Watches argocd/applications/)              │
└────────────────────────────┬────────────────────────────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│ backend.yaml │      │frontend.yaml │      │ workers.yaml │
│ (apps/back)  │      │(apps/front)  │      │(apps/worker) │
└──────────────┘      └──────────────┘      └──────────────┘
```

1. You apply `argocd/root-application.yaml` once into your cluster.
2. The root application continuously monitors the Git repository at path `argocd/applications/`.
3. Whenever you add, modify, or remove an Application YAML in `argocd/applications/`, ArgoCD detects it and automatically syncs the underlying resources into the cluster.

---

## 🛠 How to Customize for Your Organization

Before deploying, update the repository URL to match your GitHub repository:

```bash
# Run this one-liner from the project root to update all ArgoCD manifests:
find argocd/ -name "*.yaml" -exec sed -i 's|YOUR_ORG|your-github-username|g' {} \;
```

### Key Configurations to Review:
* **Target Revision**: Default is `HEAD` (or `main`). Can be pinned to release tags (e.g. `v1.2.0`).
* **Self-Heal**: `spec.syncPolicy.automated.selfHeal: true` reverts manual `kubectl` edits to match Git state.
* **Prune**: `spec.syncPolicy.automated.prune: true` deletes resources from the cluster when deleted from Git.

---

## 🧪 Testing on Local KinD Cluster

```bash
# 1. Switch context:
kubectl config use-context kind-bnp-cluster

# 2. Apply the AppProject security boundary:
kubectl apply -f argocd/app-project.yaml -n argocd

# 3. Apply the Root Application:
kubectl apply -f argocd/root-application.yaml -n argocd

# 4. Check synchronization:
kubectl get applications -n argocd
```

---

## 🧪 Testing on Amazon EKS

```bash
# 1. Authenticate to EKS:
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>

# 2. Apply GitOps bootstrap:
kubectl apply -f argocd/app-project.yaml -n argocd
kubectl apply -f argocd/root-application.yaml -n argocd

# 3. Monitor sync progress via ArgoCD CLI:
argocd app list
argocd app get root-application
```

---

## 🔧 Useful Operational Commands

```bash
# Force a hard refresh and manual sync:
argocd app sync root-application --force

# Sync a specific application only:
argocd app sync backend

# Inspect diff between cluster state and Git:
argocd app diff backend
```
