# 🚀 DevOps Starter Kit

> **Production-Grade Cloud Infrastructure & Kubernetes GitOps Platform for Amazon EKS**  
> An end-to-end, modular DevOps foundation providing AWS infrastructure automation via Terraform, automated cluster bootstrapping, enterprise Kubernetes platform baselines, universal Helm microservice charts, multi-environment configuration, continuous reconciliation via ArgoCD, and automated CI/CD pipelines.

[![GitOps Ready](https://img.shields.io/badge/GitOps-ArgoCD-blue.svg?logo=argo&logoColor=white)](https://argoproj.github.io/argo-cd/)
[![Terraform Ready](https://img.shields.io/badge/IaC-Terraform-purple.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![EKS Compatible](https://img.shields.io/badge/AWS-Amazon%20EKS-orange.svg?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Helm 3](https://img.shields.io/badge/Helm-3.x-blueviolet.svg?logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus Stack](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-red.svg?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Zero Trust Security](https://img.shields.io/badge/Security-NetworkPolicy%20%2B%20IRSA-green.svg)](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📋 Table of Contents

1. [Platform Overview & Core Pillars](#-platform-overview--core-pillars)
2. [Architecture Diagram](#-architecture-diagram)
3. [Repository Directory Structure](#-repository-directory-structure)
4. [Quick Start (5-Minute Bootstrap)](#-quick-start-5-minute-bootstrap)
5. [AWS Cloud Infrastructure (Terraform & Scripts)](#-aws-cloud-infrastructure-terraform--scripts)
6. [Bootstrap Layer (Platform Installer)](#-bootstrap-layer-platform-installer)
7. [ArgoCD & GitOps Engine](#-argocd--gitops-engine)
8. [Platform Infrastructure Components](#-platform-infrastructure-components)
   - [Namespaces & Pod Security Standards](#1-namespaces--pod-security-standards)
   - [Networking: Services & Ingress (ALB & NGINX)](#2-networking-services--ingress)
   - [Storage: EBS, EFS & emptyDir](#3-storage-ebs-efs--emptydir)
   - [Security: RBAC, NetworkPolicy, PDB & PriorityClasses](#4-security-rbac-networkpolicy-pdb--priorityclasses)
   - [Policies: ResourceQuotas & LimitRanges](#5-policies-resourcequotas--limitranges)
   - [Monitoring: Prometheus, Grafana, Alerts & Dashboards](#6-monitoring-prometheus-grafana-alerts--dashboards)
9. [Application Templates (FastAPI, React, Celery/Worker, CronJob)](#-application-templates)
   - [Backend REST API (FastAPI / Express / Spring)](#1-backend-appsbackend)
   - [Frontend SPA (React + NGINX)](#2-frontend-appsfrontend)
   - [Background Worker (Python Celery / SQS / BullMQ)](#3-worker-appsworker)
   - [Scheduled CronJobs (Batch / Reports / Cleanup)](#4-cronjob-appscronjob)
   - [Universal 8-File Standard](#universal-8-file-standard-across-all-apps)
10. [Helm Starter Chart](#-helm-starter-chart)
11. [Multi-Environment Management (Dev, Staging, Prod)](#-multi-environment-management)
12. [GitOps CI/CD Workflow & Pipeline Starter Kit](#-gitops-cicd-workflow--pipeline-starter-kit)
13. [AWS Compatibility & IRSA Placeholders](#-aws-compatibility--irsa-placeholders)
14. [5-Minute Rapid Customization Checklist](#-5-minute-rapid-customization-checklist)
15. [Operational Runbook & Troubleshooting](#-operational-runbook--troubleshooting)

---

## 💡 Platform Overview & Core Pillars

The **DevOps Starter Kit** delivers an **enterprise-grade, production-ready DevOps & GitOps foundation** designed to take applications from zero to a resilient, self-healing cloud deployment on Amazon EKS with zero YAML duplication and best-in-class security defaults.

This platform comprises nine core architectural pillars:

1. **AWS Infrastructure Layer (`terraform/`)**: Modular Terraform configurations that provision complete AWS infrastructure up to Amazon EKS — including VPC, public/private subnets, Internet Gateways, NAT Gateways, EKS control plane, managed node groups, and IAM roles with OIDC provider for IRSA.
2. **Terraform Automation Scripts (`terraform scripts/`)**: Executable helper scripts (`init.sh`, `apply.sh`, `destroy.sh`, `verify.sh`) to initialize, apply, validate, and clean up AWS cloud infrastructure safely and idempotently.
3. **Cluster Bootstrap Installer (`bootstrap/`)**: A single idempotent script that installs essential cluster addons: ArgoCD GitOps controller, kube-prometheus-stack (Prometheus & Grafana), AWS Load Balancer Controller, Kubernetes Metrics Server, External Secrets Operator, and AWS EBS/EFS CSI drivers.
4. **Platform Infrastructure Baselines (`platform/`)**: Hardened Kubernetes manifests defining standard Namespaces with Pod Security Standards (PSS), StorageClasses (gp3 & EFS), Zero-Trust NetworkPolicies, RBAC Roles/Bindings, ResourceQuotas, LimitRanges, PodDisruptionBudgets, and PriorityClasses.
5. **GitOps Engine (`argocd/`)**: Declarative ArgoCD App-of-Apps root configurations and ApplicationSet templates that continuously reconcile live cluster workloads against this Git repository, providing instant drift detection and automated self-healing.
6. **Universal Microservice Chart (`helm/starter-chart/`)**: A single parameterized Helm chart capable of deploying any REST API backend, client SPA frontend, asynchronous queue worker, or scheduled CronJob with clean multi-environment override support.
7. **Multi-Environment Management (`environments/`)**: Dedicated environment values (`dev`, `staging`, `prod`, `local`) implementing a cascading configuration model for clean multi-tenant isolation.
8. **Universal Application Templates (`apps/`)**: Production workload templates for FastAPI/REST APIs, React SPA frontends, background workers, and batch CronJobs adhering to the universal 8-file Kubernetes standard.
9. **CI Pipeline Starter Kit (`CI pipeline/`)**: Standalone, production-style CI pipelines for GitHub Actions and Jenkins featuring automated testing, Docker container builds, Aqua Security Trivy vulnerability scanning, dual registry support (Docker Hub & Amazon ECR), and automated GitOps Pull Request creation.

---

## 🏗 Architecture Diagram

```
                                  ┌───────────────────────────────────────────────────────────┐
                                  │                     AWS Cloud (VPC)                       │
                                  │                                                           │
                                  │   ┌────────────────────┐         ┌────────────────────┐   │
                                  │   │  AWS ACM (SSL/TLS) │         │  AWS WAFv2 WebACL  │   │
                                  │   └─────────┬──────────┘         └─────────┬──────────┘   │
                                  │             │                              │              │
                                  │             ▼                              ▼              │
                                  │   ┌───────────────────────────────────────────────────┐   │
                                  │   │        AWS Application Load Balancer (ALB)        │   │
                                  │   │            Internet-Facing / Internal             │   │
                                  │   └─────────────────────────┬─────────────────────────┘   │
                                  │                             │                             │
                                  │   ══════════════════════════╪══════════════════════════   │
                                  │   │               Amazon EKS Cluster                  │   │
                                  │   │                                                   │   │
                                  │   │  ┌──────────────┐         ┌────────────────────┐  │   │
                                  │   │  │ ArgoCD GitOps│────────▶│ Platform Core      │  │   │
                                  │   │  │  Controller  │         │ - Namespaces (PSS) │  │   │
                                  │   │  └──────┬───────┘         │ - StorageClasses   │  │   │
                                  │   │         │                 │ - RBAC & Policies  │  │   │
                                  │   │         │                 │ - NetworkPolicies  │  │   │
                                  │   │         │                 └────────────────────┘  │   │
                                  │   │         ▼                                         │   │
                                  │   │  ┌─────────────────────────────────────────────┐  │   │
                                  │   │  │ Workload Pods (apps namespace)              │  │   │
                                  │   │  │  ┌───────────┐  ┌───────────┐  ┌──────────┐ │  │   │
                                  │   │  │  │  Frontend │  │  Backend  │  │  Worker  │ │  │   │
                                  │   │  │  │(React+NGX)│─▶│ (REST API)│─▶│ (Queues) │ │  │   │
                                  │   │  │  └─────┬─────┘  └─────┬─────┘  └────┬─────┘ │  │   │
                                  │   │  │        │              │             │       │  │   │
                                  │   │  │        │     ┌────────┴────────┐    │       │  │   │
                                  │   │  │        │     │ CronJob / Batch │    │       │  │   │
                                  │   │  │        │     └─────────────────┘    │       │  │   │
                                  │   │  └────────┼────────────────────────────┼───────┘  │   │
                                  │   │           ▼                            ▼          │   │
                                  │   │  ┌─────────────────┐          ┌────────────────┐  │   │
                                  │   │  │ kube-prometheus │◀─────────┤ Metrics Server │  │   │
                                  │   │  │ Grafana / Alert │          │ (HPA Metrics)  │  │   │
                                  │   │  └─────────────────┘          └────────────────┘  │   │
                                  │   ═════════════════════════════════════════════════════   │
                                  │                             │                             │
                                  │   ┌─────────────────────────┴─────────────────────────┐   │
                                  │   │ AWS Managed Services (via IRSA):                  │   │
                                  │   │  - Amazon RDS / Aurora (Postgres/MySQL)           │   │
                                  │   │  - Amazon SQS (Message queues)                    │   │
                                  │   │  - Amazon S3 (Object storage)                     │   │
                                  │   │  - AWS Secrets Manager (via External Secrets)     │   │
                                  │   │  - Amazon EBS (gp3) & Amazon EFS (Shared RWX)     │   │
                                  │   └───────────────────────────────────────────────────┘   │
                                  └───────────────────────────────────────────────────────────┘
                                                ▲
                                                │ GitOps Sync (Auto-Sync, Self-Heal)
                                  ┌─────────────┴─────────────┐
                                  │    GitHub GitOps Repo     │
                                  │    (k8s-gitops-starter)   │
                                  └───────────────────────────┘
```

---

## 📁 Repository Directory Structure

This repository strictly conforms to the production GitOps specification:

```text
devops-starter-kit/
│
├── terraform/                              # AWS Cloud Infrastructure as Code (IaC)
│   ├── main.tf                             # VPC, subnets, EKS cluster, node groups
│   ├── variables.tf                        # Configurable CIDR, regions, instance types
│   ├── outputs.tf                          # EKS endpoint, OIDC ARN, security groups
│   ├── providers.tf                        # AWS & Kubernetes providers
│   └── modules/                            # Reusable VPC & EKS sub-modules
│
├── terraform scripts/                      # Automated Terraform management scripts
│   ├── init.sh                             # Initializes remote state & backend
│   ├── apply.sh                            # Validates and executes terraform apply
│   ├── verify.sh                           # Verifies AWS EKS cluster connectivity
│   └── destroy.sh                          # Tear-down script with safety prompts
│
├── bootstrap/                              # One-command platform bootstrap installer
│   ├── install.sh                          # Idempotent platform installer script
│   ├── uninstall.sh                        # Tear-down script for platform releases
│   └── values/                             # Helm override values per platform component
│       ├── argocd.yaml                     # ArgoCD server & controller settings
│       ├── prometheus.yaml                 # Prometheus Operator & scrape configs
│       ├── grafana.yaml                    # Grafana persistence, plugins & admin config
│       ├── aws-load-balancer.yaml          # AWS LBC clusterName & IRSA values
│       ├── metrics-server.yaml             # Metrics Server args & resources
│       ├── external-secrets.yaml           # External Secrets Operator configuration
│       ├── ebs-csi.yaml                    # AWS EBS CSI driver controller settings
│       └── efs-csi.yaml                    # AWS EFS CSI driver daemonset settings
│
├── argocd/                                 # Declarative GitOps engine configuration
│   ├── root-application.yaml               # App-of-Apps root watching this repository
│   ├── app-project.yaml                    # RBAC, cluster, and namespace security boundary
│   ├── applications/                       # Target Application CRDs
│   │   ├── monitoring.yaml                 # Syncs platform/monitoring/
│   │   ├── networking.yaml                 # Syncs platform/networking/
│   │   ├── backend.yaml                    # Syncs apps/backend/
│   │   ├── frontend.yaml                   # Syncs apps/frontend/
│   │   └── workers.yaml                    # Syncs apps/worker/
│   └── applicationsets/                    # Multi-environment generation engine
│       └── env-appset.yaml                 # Generates dev/staging/prod with staged waves
│
├── platform/                               # Foundation platform infrastructure manifests
│   ├── namespaces/                         # Standardized namespaces with PSS labels
│   │   ├── apps.yaml                       # Application workloads namespace
│   │   ├── monitoring.yaml                 # Observability namespace
│   │   ├── platform.yaml                   # Shared platform services namespace
│   │   └── argocd.yaml                     # GitOps engine namespace
│   ├── networking/                         # Reusable Services and Ingress manifests
│   │   ├── clusterip.yaml                  # Default internal service-to-service
│   │   ├── loadbalancer.yaml               # AWS Network Load Balancer (NLB) for TCP/UDP
│   │   ├── nodeport.yaml                   # NodePort service for testing/legacy
│   │   ├── headless.yaml                   # Headless service for StatefulSets & discovery
│   │   ├── alb-ingress.yaml                # AWS Application Load Balancer Ingress
│   │   └── nginx-ingress.yaml              # Community NGINX Ingress Controller manifest
│   ├── storage/                            # Dynamic cloud storage classes & PVC templates
│   │   ├── ebs-storageclass.yaml           # EBS gp3, gp2, io1 StorageClasses (RWO)
│   │   ├── ebs-pvc.yaml                    # EBS PersistentVolumeClaim template
│   │   ├── efs-storageclass.yaml           # EFS StorageClass (RWX shared filesystem)
│   │   ├── efs-pvc.yaml                    # EFS PersistentVolumeClaim template
│   │   └── emptydir-example.yaml           # High-speed scratch ephemeral storage
│   ├── security/                           # Enterprise security & RBAC baselines
│   │   ├── serviceaccount.yaml             # ServiceAccount with IRSA annotations
│   │   ├── role.yaml                       # Namespace-scoped least-privilege Role
│   │   ├── rolebinding.yaml                # RoleBinding connecting SA to Role
│   │   ├── clusterrole.yaml                # Cluster-scoped discovery ClusterRole
│   │   ├── clusterrolebinding.yaml         # ClusterRoleBinding template
│   │   ├── networkpolicy.yaml              # Zero-Trust default-deny + allow rules
│   │   ├── poddisruptionbudget.yaml        # PDB for zero-downtime maintenance
│   │   └── priorityclass.yaml              # Production vs default workload PriorityClasses
│   ├── policies/                           # Multi-tenant resource boundaries
│   │   ├── resourcequota.yaml              # CPU, memory, and pod count quotas
│   │   └── limitrange.yaml                 # Default/min/max container limits
│   └── monitoring/                         # Declarative observability manifests
│       ├── servicemonitor.yaml             # Prometheus Operator ServiceMonitor
│       ├── podmonitor.yaml                 # Prometheus Operator PodMonitor
│       ├── prometheusrule.yaml             # Alerts (down pods, 5xx, latency, restart loops)
│       ├── alertmanager-config.yaml        # Slack/PagerDuty/Email Alertmanager routing
│       └── dashboards/                     # Grafana dashboard definitions
│           └── README.md                   # Instructions for provisioning ConfigMap dashboards
│
├── apps/                                   # Standalone Kubernetes application manifests
│   ├── backend/                            # REST API (FastAPI / Express / Spring)
│   │   ├── deployment.yaml                 # Production Deployment (probes, securityContext)
│   │   ├── service.yaml                    # ClusterIP Service
│   │   ├── ingress.yaml                    # AWS ALB Ingress with TLS redirect
│   │   ├── configmap.yaml                  # Non-sensitive runtime configuration
│   │   ├── secret.yaml                     # Secret placeholder & ExternalSecret guide
│   │   ├── hpa.yaml                        # HorizontalPodAutoscaler (CPU & memory)
│   │   ├── serviceaccount.yaml             # Workload ServiceAccount with IRSA
│   │   └── pvc.yaml                        # Optional persistent volume claim
│   ├── frontend/                           # Client-side web application (React + NGINX)
│   │   ├── deployment.yaml                 # React NGINX deployment with security headers
│   │   ├── service.yaml                    # Frontend ClusterIP Service
│   │   ├── ingress.yaml                    # Public ALB Ingress
│   │   ├── configmap.yaml                  # NGINX configuration (SPA routing, gzip)
│   │   ├── secret.yaml                     # Frontend secrets template
│   │   ├── hpa.yaml                        # Autoscaling for traffic surges
│   │   ├── serviceaccount.yaml             # Dedicated ServiceAccount
│   │   └── pvc.yaml                        # Optional storage claim
│   ├── worker/                             # Asynchronous queue consumer (Celery / SQS)
│   │   ├── deployment.yaml                 # Worker Deployment (graceful shutdown)
│   │   ├── service.yaml                    # Headless Service for Prometheus scraping
│   │   ├── ingress.yaml                    # Optional ALB Ingress for admin/webhooks
│   │   ├── configmap.yaml                  # Queue endpoints & concurrency settings
│   │   ├── secret.yaml                     # Broker credentials template
│   │   ├── hpa.yaml                        # Burst autoscaling configuration
│   │   ├── serviceaccount.yaml             # IRSA ServiceAccount for SQS/S3 access
│   │   └── pvc.yaml                        # Local disk cache claim
│   └── cronjob/                            # Scheduled background tasks
│       ├── cronjob.yaml                    # Native batch/v1 CronJob manifest
│       ├── deployment.yaml                 # Continuous scheduler runner alternative
│       ├── service.yaml                    # Metrics & health check endpoint
│       ├── ingress.yaml                    # Ingress for manual webhook triggers
│       ├── configmap.yaml                  # Job configuration & parameters
│       ├── secret.yaml                     # Database/API access credentials
│       ├── hpa.yaml                        # Autoscaler template for worker runners
│       ├── serviceaccount.yaml             # IRSA ServiceAccount for cloud batch jobs
│       └── pvc.yaml                        # Claim for reports and data export files
│
├── helm/
│   └── starter-chart/                      # Unified reusable microservice Helm chart
│       ├── Chart.yaml                      # Chart metadata
│       ├── values.yaml                     # Production-ready defaults
│       ├── values-dev.yaml                 # Development overrides (single pod, debug)
│       ├── values-prod.yaml                # Production overrides (HA, WAF, strict HPA)
│       └── templates/                      # Helm template engine
│           ├── _helpers.tpl                # Standard label and naming helpers
│           ├── deployment.yaml             # Dynamic deployment with checksum reloading
│           ├── service.yaml                # Dynamic ClusterIP/LoadBalancer service
│           ├── ingress.yaml                # Parameterized ALB/NGINX Ingress
│           ├── configmap.yaml              # Key-value ConfigMap generation
│           ├── secret.yaml                 # Kubernetes Secret generation
│           ├── hpa.yaml                    # HorizontalPodAutoscaler template
│           ├── pvc.yaml                    # PersistentVolumeClaim template
│           └── serviceaccount.yaml         # ServiceAccount with IRSA annotations
│
├── environments/                           # GitOps environment values for CI/CD PRs
│   ├── dev/values.yaml                     # Dev overrides (only image.tag modified in CI)
│   ├── staging/values.yaml                 # Staging overrides (2 replicas, HPA enabled)
│   └── prod/values.yaml                    # Production overrides (HA, high resource bounds)
│
├── CI pipeline/                            # Standalone CI pipeline templates
│   ├── README.md                           # Complete CI setup & customization guide
│   ├── actions-config.md                   # Secrets & variables reference guide
│   ├── Jenkinsfile                         # Declarative standalone Jenkins pipeline
│   └── workflows/
│       └── ci.yml                          # Standalone GitHub Actions workflow
│
└── README.md                               # Complete platform manual & quick reference
```

---

## ⚡ Quick Start (5-Minute Bootstrap)

Follow these 5 steps to bootstrap the platform on any existing EKS cluster.

### Prerequisites

* `kubectl` (v1.27+) configured and authenticated to your EKS cluster:
  ```bash
  aws eks update-kubeconfig --region <AWS_REGION> --name <CLUSTER_NAME>
  kubectl get nodes
  ```
* `helm` (v3.10+) installed locally.
* `git` and `bash`.

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR_ORG/devops-starter-kit.git
cd devops-starter-kit
```

### Step 2: Set Environment Variables & Run Bootstrap

```bash
# Provide your cluster context
export CLUSTER_NAME="my-eks-cluster"
export AWS_REGION="us-east-1"

# Run the idempotent platform installer
chmod +x bootstrap/install.sh bootstrap/uninstall.sh
./bootstrap/install.sh
```

> **Dry-Run Preview**: To inspect all Helm commands without executing them, run `./bootstrap/install.sh --dry-run`.

### Step 3: Retrieve ArgoCD Admin Credentials

```bash
# Retrieve the auto-generated admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo

# Port-forward the ArgoCD Web UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
* Access the UI at `https://localhost:8080` (Username: `admin`).

### Step 4: Configure Git Repository URL in ArgoCD Manifests

Update the Git repository URL to point to your repository:
```bash
# Replace YOUR_ORG with your GitHub username or organization
find argocd/ -name "*.yaml" -exec sed -i 's|YOUR_ORG|your-github-username|g' {} \;

git add argocd/
git commit -m "chore: configure GitOps repo URL"
git push origin main
```

### Step 5: Apply ArgoCD App-of-Apps Bootstrap

```bash
# 1. Apply the security AppProject
kubectl apply -f argocd/app-project.yaml -n argocd

# 2. Apply the root App-of-Apps application
kubectl apply -f argocd/root-application.yaml -n argocd
```

ArgoCD will immediately detect your repository, sync the platform namespaces, security policies, networking, storage, monitoring, and application workloads!

---

## 🚀 Bootstrap Layer (Platform Installer)

The bootstrap layer in `bootstrap/` installs all cluster-wide infrastructure components via Helm 3 before application deployment begins.

### Components Installed by `bootstrap/install.sh`

| Component | Chart Repository | Namespace | Description | Values File |
|---|---|---|---|---|
| **ArgoCD** | `argo/argo-cd` | `argocd` | Declarative GitOps continuous delivery controller | `bootstrap/values/argocd.yaml` |
| **kube-prometheus-stack** | `prometheus-community/kube-prometheus-stack` | `monitoring` | Prometheus, Alertmanager, and Grafana stack | `bootstrap/values/prometheus.yaml`, `grafana.yaml` |
| **Metrics Server** | `metrics-server/metrics-server` | `kube-system` | Lightweight resource metrics collector required by HPA | `bootstrap/values/metrics-server.yaml` |
| **AWS Load Balancer Controller** | `eks/aws-load-balancer-controller` | `kube-system` | Dynamic controller provisioning AWS Application & Network Load Balancers | `bootstrap/values/aws-load-balancer.yaml` |
| **External Secrets Operator** | `external-secrets/external-secrets` | `external-secrets` | Synchronizes Kubernetes Secrets from AWS Secrets Manager & SSM | `bootstrap/values/external-secrets.yaml` |
| **AWS EBS CSI Driver** | `aws-ebs-csi-driver/aws-ebs-csi-driver` | `kube-system` | Manages dynamic provisioning and mounting of EBS volumes | `bootstrap/values/ebs-csi.yaml` |
| **AWS EFS CSI Driver** | `aws-efs-csi-driver/aws-efs-csi-driver` | `kube-system` | Manages dynamic provisioning of shared EFS network filesystems | `bootstrap/values/efs-csi.yaml` |

### Script Features & Idempotency

* **Safe Re-runs**: The script checks whether each Helm release is already installed. If present, it executes `helm upgrade` instead of failing.
* **Auto-Creation of Namespaces**: Creates `argocd`, `monitoring`, `external-secrets`, and `apps` namespaces automatically.
* **Non-Interactive Execution**: Designed for automated CI/CD runners and terminal scripts with zero prompt blocking.
* **Graceful Teardown**: Run `./bootstrap/uninstall.sh` to remove all platform Helm releases in reverse dependency order.

---

## 🔄 ArgoCD & GitOps Engine

The `argocd/` directory contains complete declarative GitOps manifests following the industry-standard **App-of-Apps** pattern.

### 1. Root Application (`argocd/root-application.yaml`)

The entry point for cluster synchronization:
* **Source**: Watches `argocd/applications/` in this repository on the `main` branch.
* **Sync Policy**:
  * `automated.prune: true` — Automatically deletes resources in the cluster when removed from Git.
  * `automated.selfHeal: true` — Reverts manual `kubectl` changes in the cluster back to the Git state.
* **Sync Options**: `CreateNamespace=true`, `ApplyOutOfSyncOnly=true`.

### 2. AppProject (`argocd/app-project.yaml`)

Enforces security boundaries across teams and namespaces:
* Restricts destination namespaces to `apps`, `apps-*`, `monitoring`, `platform`, and `argocd`.
* Restricts target clusters to `in-cluster` (`https://kubernetes.default.svc`).
* Whitelists authorized Git repository origins.
* Blacklists cluster-scoped security modifications by application developers.

### 3. Application CRDs (`argocd/applications/`)

Individual Application manifests provide granular deployment control:
* `monitoring.yaml`: Syncs `platform/monitoring/` into the `monitoring` namespace.
* `networking.yaml`: Syncs `platform/networking/` into the `platform` namespace.
* `backend.yaml`: Syncs `apps/backend/` into the `apps` namespace.
* `frontend.yaml`: Syncs `apps/frontend/` into the `apps` namespace.
* `workers.yaml`: Syncs `apps/worker/` into the `apps` namespace.

### 4. ApplicationSet (`argocd/applicationsets/env-appset.yaml`)

Generates identical application stacks across environments (`dev`, `staging`, `prod`) using a List generator with **staged rollout waves**:
```
Stage 1: dev (Sync wave 1) ──▶ Stage 2: staging (Sync wave 2) ──▶ Stage 3: prod (Sync wave 3)
```

---

## 🏛 Platform Infrastructure Components

### 1. Namespaces & Pod Security Standards
Located in `platform/namespaces/`:
* `apps.yaml`, `monitoring.yaml`, `platform.yaml`, `argocd.yaml`
* Enforces Kubernetes **Pod Security Standards (PSS)**:
  * `pod-security.kubernetes.io/enforce: baseline` (prevents known privilege escalations)
  * `pod-security.kubernetes.io/audit: restricted` (logs hardening violations)
  * `pod-security.kubernetes.io/warn: restricted` (warns developers at admission time)

### 2. Networking: Services & Ingress
Located in `platform/networking/`:
* **Services**:
  * `clusterip.yaml`: Internal high-performance service-to-service communication.
  * `loadbalancer.yaml`: AWS Network Load Balancer (NLB) for TCP/UDP with IP-target type and cross-zone load balancing.
  * `nodeport.yaml`: Direct node-port exposure for dev/staging test suites.
  * `headless.yaml`: ClusterIP `None` for stateful databases and direct pod discovery.
* **Ingress**:
  * `alb-ingress.yaml`: AWS Application Load Balancer with annotations for:
    * `alb.ingress.kubernetes.io/scheme`: `internet-facing` or `internal`
    * `alb.ingress.kubernetes.io/target-type`: `ip` (direct VPC pod routing without NodePort overhead)
    * `alb.ingress.kubernetes.io/ssl-redirect`: `"443"` (automatic HTTP to HTTPS redirection)
    * `alb.ingress.kubernetes.io/certificate-arn`: AWS ACM certificate integration
    * `alb.ingress.kubernetes.io/wafv2-acl-arn`: Commented AWS WAF integration
    * `alb.ingress.kubernetes.io/target-group-attributes`: Stickiness configuration (`stickiness.enabled=true`)
  * `nginx-ingress.yaml`: Ingress manifest using the community NGINX Ingress Controller.

### 3. Storage: EBS, EFS & emptyDir
Located in `platform/storage/`:
* `ebs-storageclass.yaml`: Dynamic Amazon EBS CSI provisioner (`ebs.csi.aws.com`):
  * `ebs-gp3` (Default): General purpose SSD with configurable IOPS and throughput, encrypted via AWS KMS.
  * `ebs-gp2`: Legacy compatibility class.
  * `ebs-io1`: High-performance provisioned IOPS SSD for transactional databases.
  * `volumeBindingMode: WaitForFirstConsumer` (ensures volumes are provisioned in the same Availability Zone as the scheduled pod).
* `efs-storageclass.yaml`: Amazon EFS CSI provisioner (`efs.csi.aws.com`):
  * Dynamic `ReadWriteMany` (RWX) multi-pod concurrent access.
* `emptydir-example.yaml`: High-speed memory-backed or local SSD scratch volumes.

### 4. Security: RBAC, NetworkPolicy, PDB & PriorityClasses
Located in `platform/security/`:
* **Least-Privilege RBAC**:
  * `serviceaccount.yaml`: Pre-configured with AWS IRSA annotation placeholders (`eks.amazonaws.com/role-arn`).
  * `role.yaml` & `rolebinding.yaml`: Strict namespace-scoped permissions.
  * `clusterrole.yaml` & `clusterrolebinding.yaml`: Cluster-wide read-only discovery permissions.
* **Zero-Trust NetworkPolicy (`networkpolicy.yaml`)**:
  * Default deny-all ingress and egress for workloads.
  * Explicitly allows intra-namespace traffic.
  * Explicitly allows ingress from frontend to backend on port 8000.
  * Explicitly allows Prometheus scraper access from `monitoring` namespace.
  * Explicitly allows CoreDNS egress on UDP/TCP port 53.
* **High Availability & Scheduling**:
  * `poddisruptionbudget.yaml`: Enforces `minAvailable: 1` or `maxUnavailable: 25%` during cluster node upgrades.
  * `priorityclass.yaml`: `production-critical` (value: 1000000) and `platform-infrastructure` (value: 900000) ensuring critical pods are never evicted before batch jobs.

### 5. Policies: ResourceQuotas & LimitRanges
Located in `platform/policies/`:
* `resourcequota.yaml`: Limits namespace consumption to prevent cluster starvation:
  * CPU requests: 20 cores, Memory requests: 40Gi
  * Maximum 50 Pods, 10 LoadBalancers, 20 PVCs.
* `limitrange.yaml`: Enforces default container requests (`100m` CPU / `128Mi` RAM) and limits (`500m` CPU / `512Mi` RAM) if not declared by developers.

### 6. Monitoring: Prometheus, Grafana, Alerts & Dashboards
Located in `platform/monitoring/`:
* `servicemonitor.yaml`: Automatically scrapes any Service with label `monitoring: enabled`.
* `podmonitor.yaml`: Scrapes pods without requiring an associated Kubernetes Service.
* `prometheusrule.yaml`: Pre-configured production alerting rules:
  * `StarterAppDown`: Pod replicas = 0 for >1 minute (Critical).
  * `HighPodRestartRate`: Pod restarting >5 times in 15 minutes (Warning).
  * `HighErrorRate`: HTTP 5xx error rate > 5% over 5 minutes (Warning).
  * `SlowResponseTime`: 95th percentile latency > 2 seconds (Warning).
  * `CPUThrottling`: Container CPU throttled > 25% of runtime (Warning).
  * `HighMemoryUsage`: Memory usage > 85% of limit (Warning).
* `alertmanager-config.yaml`: Routes alerts to Slack webhooks, PagerDuty, or Email.

---

## 📦 Application Templates

The `apps/` directory provides complete manifest sets for the four primary cloud-native workload patterns.

### Universal 8-File Standard Across All Apps

Every application directory contains the exact same 8 standardized files:

| File | Purpose in `apps/backend` | Purpose in `apps/frontend` | Purpose in `apps/worker` | Purpose in `apps/cronjob` |
|---|---|---|---|---|
| `deployment.yaml` | REST API (rolling update) | React + NGINX SPA | Queue worker (graceful stop) | Continuous scheduler daemon |
| `service.yaml` | ClusterIP (port 8000) | ClusterIP (port 80) | Headless (metrics scraping) | Pushgateway / metrics endpoint |
| `ingress.yaml` | ALB API Ingress | ALB Public Web Ingress | Optional worker admin/webhook | Internal webhook / reports |
| `configmap.yaml` | App settings & DB hosts | NGINX SPA & gzip config | SQS queue & concurrency | Batch task parameters |
| `secret.yaml` | Passwords & API tokens | Frontend runtime secrets | Broker / DB credentials | Batch service credentials |
| `hpa.yaml` | CPU/Memory HPA (2–10) | Surge HPA (2–8) | Queue-burst HPA (1–10) | HPA for scheduler runner |
| `serviceaccount.yaml` | IRSA for S3/RDS | Dedicated SA | IRSA for SQS/DynamoDB | IRSA for S3 batch exports |
| `pvc.yaml` | Optional file storage | Optional asset cache | Local disk cache | Batch output reports disk |

> **Note for CronJob**: In addition to the 8 standard manifests, `apps/cronjob/` includes `cronjob.yaml` which defines the native scheduled Kubernetes batch job (`batch/v1`).

---

### 1. Backend (`apps/backend`)
* **Ideal for**: FastAPI, Express.js, Flask, NestJS, Spring Boot, Go Gin.
* **Key Features**:
  * Full three-tier health probing (`readinessProbe`, `livenessProbe`, `startupProbe`).
  * Non-root execution (`runAsUser: 1000`), read-only root filesystem with ephemeral `/tmp` mount.
  * Pod anti-affinity to ensure replicas spread across different Availability Zones (`topologyKey: topology.kubernetes.io/zone`).
  * `HorizontalPodAutoscaler` scaling from 2 to 10 replicas based on 70% CPU and 80% RAM utilization.

### 2. Frontend (`apps/frontend`)
* **Ideal for**: React, Vue, Angular, Next.js (export), static SPA sites.
* **Key Features**:
  * ConfigMap-driven NGINX configuration supporting client-side SPA routing (`try_files $uri $uri/ /index.html`), gzip compression, and security headers (CSP, X-Frame-Options, X-Content-Type-Options).
  * Non-root NGINX container writing cache and pid files to tmpfs volumes.
  * Public AWS ALB Ingress with SSL redirect.

### 3. Worker (`apps/worker`)
* **Ideal for**: Python Celery, BullMQ, AWS SQS consumers, Kafka consumers.
* **Key Features**:
  * Extended `terminationGracePeriodSeconds: 120` to allow running background tasks to complete before SIGKILL.
  * Scaled-down HPA policy with immediate scale-up and 300-second stabilization scale-down to prevent queue flap.
  * Pre-configured AWS IAM Role (IRSA) for SQS queue polling and DynamoDB access.

### 4. CronJob (`apps/cronjob`)
* **Ideal for**: Scheduled reports, database maintenance, ETL syncs, nightly cleanup.
* **Key Features**:
  * Standard cron syntax with explicit UTC timezone (`schedule: "0 2 * * *"`).
  * `concurrencyPolicy: Forbid` preventing overlapping runs.
  * `ttlSecondsAfterFinished: 86400` for automatic pod cleanup after 24 hours.
  * Spot instance tolerations allowing batch jobs to run on cost-saving AWS Spot nodes.

---

## 🛠 Helm Starter Chart

The `helm/starter-chart/` directory is a **universal, highly parameterized Helm chart** that replaces YAML duplication across microservices.

### Testing & Linting the Chart

```bash
# Lint the chart
helm lint helm/starter-chart/

# Render templates with default values
helm template my-release helm/starter-chart/

# Render with production overrides
helm template my-release helm/starter-chart/ -f helm/starter-chart/values-prod.yaml
```

### Chart Values Cascade

```
helm/starter-chart/values.yaml (Base defaults)
         │
         ├──▶ helm/starter-chart/values-dev.yaml (Dev environment tweaks)
         └──▶ helm/starter-chart/values-prod.yaml (Production HA & WAF)
```

### Supported Values Features

* **Image Configuration**: Repository, tag, pullPolicy, imagePullSecrets.
* **Replicas & Rollout Strategy**: Configurable rolling update parameters (`maxUnavailable: 0`, `maxSurge: 1`).
* **Ingress**: Enable/disable, ingressClassName (ALB or NGINX), annotations, multi-host TLS rules.
* **Autoscaling (HPA)**: Min/max replicas, CPU target percentage, memory target percentage.
* **Persistence**: Dynamic PVC creation, storageClassName selection, size requests.
* **Security Contexts**: Pod-level and container-level least-privilege security settings.
* **Config & Secrets**: Map arbitrary key-value pairs directly into mounted ConfigMaps and Secrets.
* **Scheduling**: NodeSelectors, tolerations, and pod anti-affinity.

---

## 🌍 Multi-Environment Management

The `environments/` directory enables clean, multi-tenant GitOps environments managed by ArgoCD:

```text
environments/
├── dev/values.yaml        # 1 replica, internal ALB, debug logging, relaxed resources
├── staging/values.yaml    # 2 replicas, production-like testing, HPA enabled
└── prod/values.yaml       # HA (3+ replicas), Multi-AZ anti-affinity, WAF, strict HPA
```

### Manual Per-Environment Deployment Example

```bash
# Deploy to Dev
helm upgrade --install backend-dev helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/dev/values.yaml \
  --namespace apps-dev --create-namespace

# Deploy to Production
helm upgrade --install backend-prod helm/starter-chart/ \
  -f helm/starter-chart/values.yaml \
  -f environments/prod/values.yaml \
  --namespace apps-prod --create-namespace
```

---

## 🔄 GitOps CI/CD Workflow & Pipeline Starter Kit

This platform decouples application code repositories from infrastructure deployment. Ready-to-use, standalone CI templates for GitHub Actions and Jenkins are available in the [`CI pipeline/`](CI%20pipeline/README.md) directory.

```
 [Application Repository]                         [Infrastructure Repository (This Repo)]
            │                                                       │
  [Developer commits code]                                          │
            │                                                       │
            ▼                                                       │
   [CI Pipeline: GitHub Actions / Jenkins]                          │
    1. Run Unit Tests (Pytest / Jest)                               │
    2. Build Container Image                                        │
    3. Security Vulnerability Scan (Trivy)                          │
    4. Push Image (Docker Hub or Amazon ECR)                        │
    5. Commit Image Tag to GitOps Repo (Create PR) ───────────────▶ │
       (Updates environments/<env>/values.yaml)                     │
                                                                    ▼
                                                          [ArgoCD GitOps Sync]
                                                           1. Detects Git commit (post-merge)
                                                           2. Performs diff against cluster
                                                           3. Executes rolling deployment
                                                           4. Verifies health probes
                                                           5. Auto-heals if drift occurs
```

### The Only Value CI Changes

In the GitOps workflow, your application CI pipeline only updates a single value in `environments/<env>/values.yaml`:

```yaml
image:
  repository: docker.io/username/myapp
  tag: "sha-a1b2c3d"   # ← CI updates ONLY this tag via Git commit & Pull Request
```

> 📖 **Full CI Documentation**: See the [CI Pipeline Setup Guide](CI%20pipeline/README.md) for step-by-step instructions on configuring GitHub Actions (`workflows/ci.yml`), Jenkins (`Jenkinsfile`), dual-registry toggles, and secrets.

---

## 🔐 AWS Compatibility & IRSA Placeholders

This platform is engineered specifically for Amazon EKS and includes placeholders for seamless AWS service integrations without modifying application code:

| AWS Service | Integration Mechanism | Manifest File & Location |
|---|---|---|
| **IAM Roles for Service Accounts (IRSA)** | Pod identity via OIDC | `apps/*/serviceaccount.yaml` → `eks.amazonaws.com/role-arn` |
| **Amazon EBS (gp3)** | Dynamic block storage | `platform/storage/ebs-storageclass.yaml` → `kmsKeyId` |
| **Amazon EFS** | Dynamic shared filesystem | `platform/storage/efs-storageclass.yaml` → `fileSystemId` |
| **AWS Certificate Manager (ACM)** | SSL/TLS certificates | `apps/*/ingress.yaml` → `alb.ingress.kubernetes.io/certificate-arn` |
| **AWS WAFv2** | DDoS & Web Application Firewall | `apps/*/ingress.yaml` → `alb.ingress.kubernetes.io/wafv2-acl-arn` |
| **AWS Secrets Manager** | Secrets synchronization | `apps/*/secret.yaml` → `ExternalSecret` CR |
| **Amazon RDS / Aurora** | Database connectivity | `apps/*/configmap.yaml` → `DB_HOST`, `DB_PORT` |
| **Amazon SQS** | Async message queue | `apps/worker/configmap.yaml` → `SQS_QUEUE_URL` |
| **Amazon S3** | Object storage buckets | `apps/backend/configmap.yaml` → `S3_BUCKET_NAME` |

---

## ⏱ 5-Minute Rapid Customization Checklist

To adapt this starter kit for any new application or microservice in under 5 minutes:

- [ ] **Step 1: Set Image Repository & Tag**
  * Open `apps/backend/deployment.yaml` (or `environments/dev/values.yaml`).
  * Replace the image placeholder with your ECR/Docker Hub image.
- [ ] **Step 2: Configure Environment Variables**
  * Open `apps/backend/configmap.yaml`.
  * Add your database host, API URLs, and feature flags.
- [ ] **Step 3: Set Secrets**
  * Open `apps/backend/secret.yaml`.
  * Enter your database password or API keys (or configure ExternalSecret).
- [ ] **Step 4: Update Ingress Hostname**
  * Open `apps/backend/ingress.yaml` and `apps/frontend/ingress.yaml`.
  * Update `host: api.example.com` and `app.example.com`.
- [ ] **Step 5: Pick Storage (if stateful)**
  * Open `apps/backend/pvc.yaml`.
  * Choose `storageClassName: ebs-gp3` (single pod RWO) or `efs-sc` (shared RWX).
- [ ] **Step 6: Push to Git & Let ArgoCD Deploy**
  * `git add . && git commit -m "feat: customize starter kit for application" && git push`
  * ArgoCD will roll out the updated application automatically!

---

## 🛠 Operational Runbook & Troubleshooting

### Check ArgoCD Synchronization & Application Health

```bash
# List all ArgoCD applications
kubectl get applications -n argocd

# Check details of a specific app
kubectl describe application backend -n argocd

# Force manual sync and prune
kubectl -n argocd annotate application backend argocd.argoproj.io/refresh=hard
```

### Pod & Container Diagnostics

```bash
# View pod status across workloads
kubectl get pods -n apps -o wide

# Check recent pod restart reasons or crash loops
kubectl describe pod <pod-name> -n apps

# View live container logs
kubectl logs -f <pod-name> -n apps -c <container-name>

# View previous container logs if pod crashed
kubectl logs <pod-name> -n apps --previous
```

### Ingress & AWS Load Balancer Debugging

```bash
# Check Ingress status and allocated ALB DNS name
kubectl get ingress -n apps

# Inspect ALB Controller logs for provisioning errors
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=100
```

### Autoscaling & Resource Verification

```bash
# Check HorizontalPodAutoscaler metrics and target ratios
kubectl get hpa -n apps

# Check node and pod CPU/memory utilization (requires Metrics Server)
kubectl top nodes
kubectl top pods -n apps
```

### Storage & PVC Troubleshooting

```bash
# Verify PersistentVolumeClaim status
kubectl get pvc -n apps
kubectl get pv

# If PVC is Pending, check StorageClass and AZ affinity
kubectl describe pvc <pvc-name> -n apps
```

---

## 📄 License

This starter platform is licensed under the **MIT License**. Free for commercial projects, internal platform engineering, and open-source initiatives.

---

*Engineered for production reliability, zero YAML duplication, and seamless GitOps deployment.*
