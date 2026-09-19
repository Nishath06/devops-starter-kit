# ⚙️ Asynchronous Worker Workload (`apps/worker/`)

> **Production Template for Queue Workers (Python Celery, AWS SQS, BullMQ, Kafka Consumers)**

---

## 📋 Manifests in this Folder

* [`deployment.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/deployment.yaml) — Worker deployment with extended `terminationGracePeriodSeconds: 120` to allow running jobs to finish gracefully.
* [`service.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/service.yaml) — Headless service for Prometheus metrics scraping.
* [`ingress.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/ingress.yaml) — Optional ingress for worker management dashboards (e.g. Celery Flower) or incoming webhooks.
* [`configmap.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/configmap.yaml) — Queue endpoints, broker URLs, and concurrency levels.
* [`secret.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/secret.yaml) — Broker passwords and API keys.
* [`hpa.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/hpa.yaml) — HPA with aggressive scale-up (for queue bursts) and conservative 300-second scale-down stabilization.
* [`serviceaccount.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/serviceaccount.yaml) — ServiceAccount with IRSA annotations for Amazon SQS and DynamoDB.
* [`pvc.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/worker/pvc.yaml) — Persistent disk for model caching or intermediate batch files.

---

## 🛠 Quick Customization

1. **Set Queue Endpoint**: In `configmap.yaml`, update `SQS_QUEUE_URL` or `REDIS_URL`.
2. **Set IAM Role for SQS**: In `serviceaccount.yaml`, provide your AWS IAM role ARN.
3. **Graceful Shutdown**: If jobs take longer than 2 minutes to complete, increase `terminationGracePeriodSeconds` in `deployment.yaml`.

---

## 🧪 Testing

### Local KinD:
```bash
kubectl config use-context kind-bnp-cluster
kubectl apply -f apps/worker/configmap.yaml
kubectl apply -f apps/worker/secret.yaml
kubectl apply -f apps/worker/serviceaccount.yaml
kubectl apply -f apps/worker/service.yaml
kubectl apply -f apps/worker/deployment.yaml
kubectl get pods -n apps
```

### Amazon EKS:
```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>
kubectl apply -f apps/worker/ -n apps
```
