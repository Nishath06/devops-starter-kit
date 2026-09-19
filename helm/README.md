# ⎈ Helm Starter Chart (`helm/`)

> **Universal, Parameterized Microservice Chart**  
> One chart to deploy any application (FastAPI, React, Celery, Go, Node.js) through simple values overrides without writing boilerplate Kubernetes YAML.

---

## 📋 Directory Contents

```text
helm/
└── starter-chart/                  # The reusable Helm chart
    ├── Chart.yaml                  # Chart metadata and versioning
    ├── values.yaml                 # Base default values
    ├── values-dev.yaml             # Development environment overrides
    ├── values-prod.yaml            # Production environment overrides (HA, WAF, strict HPA)
    └── templates/                  # Parameterized Kubernetes templates
        ├── _helpers.tpl            # Standard naming and label helpers
        ├── deployment.yaml         # Dynamic deployment with rolling updates & probes
        ├── service.yaml            # ClusterIP / LoadBalancer service template
        ├── ingress.yaml            # Parameterized ALB / NGINX Ingress template
        ├── configmap.yaml          # Generates key-value ConfigMap from values
        ├── secret.yaml             # Generates Secret from values
        ├── hpa.yaml                # HorizontalPodAutoscaler template (CPU & Memory)
        ├── pvc.yaml                # PersistentVolumeClaim template
        └── serviceaccount.yaml     # ServiceAccount template with IRSA annotations
```

---

## ⚙️ Values File Hierarchy

Values cascade cleanly from base defaults to target environments:

```
helm/starter-chart/values.yaml (Base defaults)
         │
         ├──▶ values-dev.yaml     (1 replica, internal ALB, debug logs, relaxed resources)
         └──▶ values-prod.yaml    (3+ replicas, Multi-AZ anti-affinity, WAF, strict HPA)
```

---

## 🛠 How to Customize for Any Application

You can deploy any containerized application simply by providing custom values:

```yaml
# custom-app-values.yaml
image:
  repository: my-org/my-service
  tag: v1.0.0

service:
  port: 8080
  targetPort: 8080

ingress:
  enabled: true
  className: alb
  hosts:
    - host: my-service.example.com
      paths:
        - path: /
          pathType: Prefix

config:
  DATABASE_URL: "postgresql://user:pass@db:5432/mydb"
  ENVIRONMENT: "production"
```

---

## 🧪 Testing on Local KinD Cluster

```bash
# 1. Switch context:
kubectl config use-context kind-bnp-cluster

# 2. Lint the chart to ensure zero syntax errors:
helm lint helm/starter-chart/

# 3. Dry-run template rendering with local overrides:
helm template my-test-app helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/local/values.yaml

# 4. Deploy into KinD:
helm upgrade --install my-test-app helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/local/values.yaml \
  --namespace apps --create-namespace

# 5. Verify deployment:
kubectl get pods -n apps -l app.kubernetes.io/instance=my-test-app
```

---

## 🧪 Testing on Amazon EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>

# 1. Deploy into EKS production namespace:
helm upgrade --install my-api helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f helm/starter-chart/values-prod.yaml \
  --namespace apps-prod --create-namespace

# 2. Check rollout status:
kubectl rollout status deployment/my-api-starter-chart -n apps-prod

# 3. View created HPA:
kubectl get hpa -n apps-prod
```
