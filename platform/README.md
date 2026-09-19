# 🏛 Platform Governance & Infrastructure (`platform/`)

> **Shared Cluster-Wide Baselines, Policies & Guardrails**  
> Enforces zero-trust networking, storage abstractions, multi-tenant resource quotas, security hardening, and Prometheus observability across all workloads.

---

## 📋 Directory Contents

```text
platform/
├── namespaces/         # Cluster namespaces with Pod Security Standards (PSS)
│   ├── apps.yaml       # Workload namespace
│   ├── monitoring.yaml # Observability namespace
│   ├── platform.yaml   # Shared infrastructure services namespace
│   └── argocd.yaml     # GitOps controller namespace
│
├── networking/         # Reusable Service and Ingress templates
│   ├── clusterip.yaml  # High-performance private internal service
│   ├── loadbalancer.yaml # AWS Network Load Balancer (NLB) for TCP/UDP
│   ├── nodeport.yaml   # Direct node-port exposure for testing
│   ├── headless.yaml   # Headless service for databases and StatefulSets
│   ├── alb-ingress.yaml # AWS Application Load Balancer Ingress (SSL/WAF)
│   └── nginx-ingress.yaml # Community NGINX Ingress manifest
│
├── storage/            # Dynamic storage classes & PVC templates
│   ├── ebs-storageclass.yaml # AWS EBS gp3, gp2, io1 StorageClasses (RWO)
│   ├── ebs-pvc.yaml    # PersistentVolumeClaim for single-pod block storage
│   ├── efs-storageclass.yaml # AWS EFS StorageClass (RWX shared multi-pod storage)
│   ├── efs-pvc.yaml    # PVC template for shared file systems
│   └── emptydir-example.yaml # Temporary in-memory or SSD scratch volume
│
├── security/           # Enterprise RBAC, Zero-Trust network policies & HA
│   ├── serviceaccount.yaml # ServiceAccount with AWS IRSA annotation placeholders
│   ├── role.yaml       # Namespace-scoped least-privilege Role
│   ├── rolebinding.yaml # Binds Role to ServiceAccount
│   ├── clusterrole.yaml # Read-only discovery ClusterRole
│   ├── clusterrolebinding.yaml # Cluster-wide binding template
│   ├── networkpolicy.yaml # Zero-Trust default-deny + explicit allow rules
│   ├── poddisruptionbudget.yaml # Guarantees pod availability during node drains
│   └── priorityclass.yaml # PriorityClasses (production-critical vs default)
│
├── policies/           # Multi-tenant resource boundaries
│   ├── resourcequota.yaml # Sets caps on CPU, memory, pods, and load balancers
│   └── limitrange.yaml # Default container requests/limits guardrails
│
└── monitoring/         # Declarative Prometheus & Alertmanager CRDs
    ├── servicemonitor.yaml # Auto-scrapes Services with label 'monitoring: enabled'
    ├── podmonitor.yaml # Direct pod scraper
    ├── prometheusrule.yaml # Production alerts (5xx, latency, downtime, restarts)
    ├── alertmanager-config.yaml # Routing to Slack, PagerDuty, or Email
    └── dashboards/     # Directory for mounting Grafana JSON dashboards
```

---

## 🛠 How to Customize for Any Workload

1. **Switch Storage for Your Application**:
   * For single-pod databases/caches on EKS: Set `storageClassName: ebs-gp3`.
   * For shared multi-pod directories (ML models, reports): Set `storageClassName: efs-sc`.
   * For local KinD testing: Set `storageClassName: standard`.
2. **Configure Ingress**:
   * On **EKS**: Use `platform/networking/alb-ingress.yaml`. Update the ACM certificate ARN (`alb.ingress.kubernetes.io/certificate-arn`) and domain host.
   * On **KinD**: Use `platform/networking/nginx-ingress.yaml`.
3. **Attach AWS IAM Roles to Pods (IRSA)**:
   * Edit `platform/security/serviceaccount.yaml`:
     ```yaml
     metadata:
       annotations:
         eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<YOUR_APP_ROLE>
     ```

---

## 🧪 Testing on Local KinD Cluster

```bash
kubectl config use-context kind-bnp-cluster

# 1. Apply Namespaces:
kubectl apply -f platform/namespaces/

# 2. Apply Security Policies & RBAC:
kubectl apply -f platform/security/role.yaml
kubectl apply -f platform/security/rolebinding.yaml
kubectl apply -f platform/security/priorityclass.yaml

# 3. Apply Resource Quotas and Limits:
kubectl apply -f platform/policies/

# 4. Test PVC creation with KinD standard storage:
kubectl apply -f platform/storage/emptydir-example.yaml
kubectl get pods -n apps
```

---

## 🧪 Testing on Amazon EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>

# 1. Apply Namespaces with Pod Security Standards (PSS):
kubectl apply -f platform/namespaces/

# 2. Apply EBS GP3 StorageClass (Encrypted, WaitForFirstConsumer):
kubectl apply -f platform/storage/ebs-storageclass.yaml

# 3. Apply Zero-Trust NetworkPolicy:
kubectl apply -f platform/security/networkpolicy.yaml

# 4. Apply Production Prometheus Alert Rules:
kubectl apply -f platform/monitoring/prometheusrule.yaml

# Verify:
kubectl get storageclass
kubectl get networkpolicy -n apps
kubectl get prometheusrules -n monitoring
```
