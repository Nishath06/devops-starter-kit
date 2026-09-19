# 💻 Frontend SPA Workload (`apps/frontend/`)

> **Production Template for Client-Side SPAs (React, Vue, Angular, Next.js static export)**

---

## 📋 Manifests in this Folder

* [`deployment.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/deployment.yaml) — Non-root NGINX container serving static build artifacts with ephemeral cache mounts.
* [`service.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/service.yaml) — ClusterIP service exposing port 80.
* [`ingress.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/ingress.yaml) — Public AWS ALB Ingress with HTTPS redirection.
* [`configmap.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/configmap.yaml) — NGINX configuration with client-side SPA routing (`try_files $uri $uri/ /index.html`), gzip compression, and security headers.
* [`secret.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/secret.yaml) — Secrets template.
* [`hpa.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/hpa.yaml) — HPA scaling for web traffic surges (2 to 8 replicas).
* [`serviceaccount.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/serviceaccount.yaml) — Workload ServiceAccount.
* [`pvc.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/frontend/pvc.yaml) — Optional static assets cache claim.

---

## 🛠 Quick Customization

1. **Set Image**: Edit `image:` in `deployment.yaml` with your built frontend image.
2. **Set Ingress Host**: Edit `host: myapp.company.com` in `ingress.yaml`.
3. **SPA Routing**: The NGINX config in `configmap.yaml` is pre-configured to prevent 404 errors on browser page reloads.

---

## 🧪 Testing

### Local KinD:
```bash
kubectl config use-context kind-bnp-cluster
kubectl apply -f apps/frontend/configmap.yaml
kubectl apply -f apps/frontend/secret.yaml
kubectl apply -f apps/frontend/serviceaccount.yaml
kubectl apply -f apps/frontend/service.yaml
kubectl apply -f apps/frontend/deployment.yaml

# Test access:
kubectl port-forward svc/frontend -n apps 3000:80
# Open http://localhost:3000
```

### Amazon EKS:
```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>
kubectl apply -f apps/frontend/ -n apps
```
