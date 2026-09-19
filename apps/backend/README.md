# 🔌 Backend REST API Workload (`apps/backend/`)

> **Production Template for REST APIs (FastAPI, Express.js, Flask, Spring Boot, Go Gin)**

---

## 📋 Manifests in this Folder

* [`deployment.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/deployment.yaml) — Deployment with rolling update, startup/liveness/readiness probes, security context (non-root, read-only rootfs), and Multi-AZ pod anti-affinity.
* [`service.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/service.yaml) — ClusterIP service exposing port 8000 with `monitoring: enabled` label for Prometheus auto-discovery.
* [`ingress.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/ingress.yaml) — AWS ALB Ingress with HTTPS redirect (`443`) and IP target type.
* [`configmap.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/configmap.yaml) — Non-sensitive environment variables (DB host, log level, feature flags).
* [`secret.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/secret.yaml) — Secret template & commented production ExternalSecret (AWS Secrets Manager).
* [`hpa.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/hpa.yaml) — HorizontalPodAutoscaler scaling 2 to 10 pods on 70% CPU and 80% RAM utilization.
* [`serviceaccount.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/serviceaccount.yaml) — ServiceAccount with AWS IRSA annotation placeholders.
* [`pvc.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/backend/pvc.yaml) — Optional persistent storage claim (EBS `ebs-gp3` or EFS `efs-sc`).

---

## 🛠 Quick Customization

1. **Set Image**: Edit `image:` in `deployment.yaml`.
2. **Set Port**: If your app listens on a different port (e.g. 3000 or 8080), change `containerPort` in `deployment.yaml` and `targetPort` in `service.yaml`.
3. **Configure DB**: Set `DB_HOST` in `configmap.yaml` and `DB_PASSWORD` in `secret.yaml`.

---

## 🧪 Testing

### Local KinD:
```bash
kubectl config use-context kind-bnp-cluster
kubectl apply -f apps/backend/configmap.yaml
kubectl apply -f apps/backend/secret.yaml
kubectl apply -f apps/backend/serviceaccount.yaml
kubectl apply -f apps/backend/service.yaml
kubectl apply -f apps/backend/deployment.yaml

# Test access:
kubectl port-forward svc/backend -n apps 8000:8000
curl http://localhost:8000/health
```

### Amazon EKS:
```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>
kubectl apply -f apps/backend/ -n apps
```
