# 📦 Application Workloads (`apps/`)

> **Ready-to-Deploy Blueprints for Microservices & Scheduled Tasks**  
> Provides production-hardened manifests for the four primary cloud-native workload archetypes.

---

## 📋 Directory Contents & Archetypes

```text
apps/
├── backend/            # Generic REST API (FastAPI, Express.js, Flask, Spring Boot)
├── frontend/           # Client-side SPA (React, Vue, Angular) served via NGINX
├── worker/             # Asynchronous queue consumer (Python Celery, SQS, BullMQ)
└── cronjob/            # Scheduled background jobs, report runners & cleanup tasks
```

---

## 📐 Universal 8-File Standard Across All Workloads

Every application directory conforms to the exact same 8 standardized files:

| File | `apps/backend/` | `apps/frontend/` | `apps/worker/` | `apps/cronjob/` |
|---|---|---|---|---|
| `deployment.yaml` | REST API (RollingUpdate) | React + NGINX SPA | Queue worker (graceful stop) | Scheduler runner daemon |
| `service.yaml` | ClusterIP (Port 8000) | ClusterIP (Port 80) | Headless (metrics scraping) | Metrics / push endpoint |
| `ingress.yaml` | Public ALB API Ingress | Public ALB Web Ingress | Optional webhook/admin | Internal trigger endpoint |
| `configmap.yaml` | App settings & DB hosts | NGINX SPA & gzip config | SQS queue & concurrency | Batch task parameters |
| `secret.yaml` | Passwords & API tokens | Frontend runtime secrets | Broker / DB credentials | Batch credentials |
| `hpa.yaml` | CPU/Memory HPA (2–10) | Surge HPA (2–8) | Queue burst HPA (1–10) | HPA for scheduler runner |
| `serviceaccount.yaml` | Workload IRSA SA | Dedicated SA | IRSA for SQS/DynamoDB | IRSA for S3 batch exports |
| `pvc.yaml` | Optional file storage | Optional asset cache | Local disk cache | Batch output reports disk |

> **Special Note for CronJob**: `apps/cronjob/` also contains `cronjob.yaml` which defines the native scheduled Kubernetes batch job (`batch/v1 CronJob`).

---

## 🛠 How to Customize for Any Application

### 1. Change Container Image
Open `apps/<workload>/deployment.yaml` and update the `image:` tag:
```yaml
containers:
  - name: backend
    image: <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/my-app:v1.0.0
```
*(For local testing on KinD, you can use any Docker Hub image like `python:3.11-slim` or load a local image).*

### 2. Configure Environment Variables
Open `apps/<workload>/configmap.yaml` and add non-sensitive runtime configurations:
```yaml
data:
  APP_ENV: "production"
  DB_HOST: "my-rds-endpoint.amazonaws.com"
  LOG_LEVEL: "info"
```

### 3. Configure Secrets
Open `apps/<workload>/secret.yaml` and add sensitive keys:
```yaml
stringData:
  DB_PASSWORD: "super-secure-password"
  API_KEY: "secret-token"
```
*(In production, replace with the ExternalSecret manifest commented in that file).*

### 4. Configure Ingress Hostname
Open `apps/<workload>/ingress.yaml` and update the hostname:
```yaml
spec:
  rules:
    - host: api.mycompany.com
```

---

## 🧪 Testing on Local KinD Cluster

```bash
# 1. Switch context:
kubectl config use-context kind-bnp-cluster

# 2. Deploy Backend:
kubectl apply -f apps/backend/configmap.yaml
kubectl apply -f apps/backend/secret.yaml
kubectl apply -f apps/backend/serviceaccount.yaml
kubectl apply -f apps/backend/service.yaml
kubectl apply -f apps/backend/deployment.yaml

# 3. Verify status:
kubectl get pods -n apps
kubectl get svc -n apps

# 4. Port-forward to test locally:
kubectl port-forward svc/backend -n apps 8000:8000
# Open http://localhost:8000
```

---

## 🧪 Testing on Amazon EKS

```bash
# 1. Authenticate to EKS:
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>

# 2. Apply all backend resources at once:
kubectl apply -f apps/backend/ -n apps

# 3. Check ALB Ingress status (waits for AWS to allocate DNS address):
kubectl get ingress backend -n apps -w

# 4. Verify HorizontalPodAutoscaler:
kubectl get hpa -n apps
```
