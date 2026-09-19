# Production-Grade Terraform AWS EKS DevOps Starter Kit

A reusable, production-hardened Terraform codebase designed to provision enterprise Amazon EKS infrastructure following AWS Well-Architected Framework, EKS Best Practices, and GitOps readiness.

---

## 🏗️ Architecture Overview

```
                                  +-------------------------------------------------------------+
                                  |                         AWS REGION                          |
                                  |                         (ap-south-1)                        |
                                  |                                                             |
                                  |  +-------------------------------------------------------+  |
                                  |  |                     AWS VPC                           |  |
                                  |  |                   (10.0.0.0/16)                       |  |
                                  |  |                                                       |  |
                                  |  |  +--------------------+       +--------------------+  |  |
                                  |  |  |  Public Subnet 1   |       |  Public Subnet 2   |  |  |
                                  |  |  |    (10.0.1.0/24)   |       |    (10.0.2.0/24)   |  |  |
                                  |  |  |                    |       |                    |  |  |
                                  |  |  |  [Internet ALB]    |       |  [Internet ALB]    |  |  |
                                  |  |  |  [NAT Gateway 1]   |       |  [NAT Gateway 2]   |  |  |
                                  |  |  +---------+----------+       +---------+----------+  |  |
                                  |  |            |                            |             |  |
                                  |  |            v                            v             |  |
                                  |  |  +--------------------+       +--------------------+  |  |
                                  |  |  |  Private Subnet 1  |       |  Private Subnet 2  |  |  |
                                  |  |  |   (10.0.10.0/24)   |       |   (10.0.20.0/24)   |  |  |
                                  |  |  |                    |       |                    |  |  |
                                  |  |  |  [Worker Node 1]   |       |  [Worker Node 2]   |  |  |
                                  |  |  |  (t3.medium AL2023)|       |  (t3.medium AL2023)|  |  |
                                  |  |  +--------------------+       +--------------------+  |  |
                                  |  |                 ^                   ^                 |  |
                                  |  +-----------------|-------------------|-----------------+  |
                                  |                    |                   |                    |
                                  |                    +---------+---------+                    |
                                  |                              |                              |
                                  |         +--------------------+--------------------+         |
                                  |         |    Amazon EKS Control Plane (v1.33)     |         |
                                  |         |   - CloudWatch Logging (Audit, API)     |         |
                                  |         |   - IAM OIDC Provider (IRSA Ready)      |         |
                                  |         |   - Managed Addons: VPC-CNI, CoreDNS,   |         |
                                  |         |     Kube-Proxy, Pod Identity, EBS CSI   |         |
                                  |         +-----------------------------------------+         |
                                  +-------------------------------------------------------------+
                                                                 |
                                                                 v
                                  +-------------------------------------------------------------+
                                  |                      Amazon ECR Repos                       |
                                  |        backend | frontend | ai-model | worker               |
                                  |     (Vulnerability Scan on Push | Retain Last 10)         |
                                  +-------------------------------------------------------------+
```

---

## 📋 Prerequisites

Before applying this infrastructure, make sure you have installed:
- **Terraform** >= 1.8.0
- **AWS CLI** v2
- **kubectl** >= 1.30
- **AWS IAM Credentials** configured with sufficient permissions to create VPCs, IAM roles, EKS clusters, and ECR repositories.

```bash
aws --version
terraform -version
kubectl version --client
```

### AWS CLI Configuration
```bash
aws configure
# Enter AWS Access Key ID, Secret Access Key, Default region (ap-south-1), and json format.
```

---

## 🚀 Quick Start Workflow

### 1. Initialize Working Directory
```bash
./scripts/init.sh
```
This runs `terraform fmt`, `terraform init`, and `terraform validate`.

### 2. Configure Your Variables
Copy the example variables file:
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```
Edit `terraform.tfvars` if you want to customize the cluster name, CIDR, instance types, or region.

### 3. Plan and Apply Infrastructure
```bash
./scripts/apply.sh
```
This plans the deployment, asks for confirmation, provisions the infrastructure, and automatically executes `aws eks update-kubeconfig`.

### 4. Verify Cluster Health
```bash
./scripts/verify.sh
```
Runs 8 diagnostic health checks verifying nodes, control plane status, system pods, and managed add-ons.

---

## 🧩 Module Breakdown

| Module | Purpose | Key AWS Resources |
| :--- | :--- | :--- |
| **`networking`** | Zero-trust multi-AZ VPC layout | `aws_vpc`, `aws_subnet` (public/private), `aws_nat_gateway`, `aws_route_table`, `aws_network_acl` |
| **`iam`** | Least-privilege IAM and IRSA bridge | `aws_iam_role` (cluster & node), `aws_iam_openid_connect_provider`, policy attachments |
| **`eks`** | Production Kubernetes control plane & nodes | `aws_eks_cluster`, `aws_eks_node_group`, `aws_security_group`, `aws_cloudwatch_log_group`, `aws_eks_addon` |
| **`ecr`** | Microservice container registry | `aws_ecr_repository`, `aws_ecr_lifecycle_policy` |

---

## 💰 Estimated Monthly AWS Costs (ap-south-1)

| Component | Quantity | Sizing | Approx Cost / Month |
| :--- | :--- | :--- | :--- |
| **EKS Control Plane** | 1 | Standard EKS pricing | $73.00 ($0.10/hour) |
| **EC2 Worker Nodes** | 2 | `t3.medium` On-Demand | ~$60.74 ($0.0416/hr each) |
| **NAT Gateways** | 2 | 1 per AZ (HA mode) | ~$65.70 ($0.045/hr) + Data |
| **EBS Storage** | 2 x 50GB | gp3 general purpose SSD | ~$8.00 ($0.08/GB-mo) |
| **ECR Storage & CloudWatch** | Variable | Last 10 images + 30d logs | ~$3.00 - $5.00 |
| **Total Estimated Cost** | | | **~$210 - $220 / month** |

> 💡 **Cost Optimization Tip for Development**: Set `single_nat_gateway = true` in `terraform.tfvars` to cut one NAT Gateway and save ~$33/month!

---

## 🧹 Teardown and Cleanup

To safely tear down all infrastructure:
```bash
./scripts/destroy.sh
```
The script will prompt for safety confirmation and double-check to prevent accidental production outages.

---

## 🛠️ Troubleshooting & Frequently Asked Questions

### 1. Nodes are in `NotReady` status after apply
- **Cause**: CoreDNS or AWS VPC CNI pods may still be initializing or unable to pull images.
- **Fix**: Check `kubectl get pods -n kube-system` and ensure your worker nodes have outbound internet connectivity via the NAT Gateway.

### 2. AWS Load Balancer Controller cannot discover subnets
- **Cause**: Missing subnet discovery tags.
- **Verification**: Ensure public subnets have `kubernetes.io/role/elb = 1` and private subnets have `kubernetes.io/role/internal-elb = 1`.

### 3. `Unauthorized` error when executing `kubectl`
- **Cause**: The IAM identity executing `kubectl` is not recognized by EKS.
- **Fix**: Re-run `aws eks update-kubeconfig --region ap-south-1 --name <cluster_name>` using the exact IAM credentials that created the cluster.
