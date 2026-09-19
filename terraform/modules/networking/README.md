# AWS Networking Module for EKS

This module provisions an AWS production VPC configured specifically for Amazon EKS and Kubernetes Load Balancers in accordance with AWS Well-Architected and EKS Best Practices.

## Features
- Dynamic multi-AZ discovery with `data.aws_availability_zones`.
- 2 Public Subnets tagged with `kubernetes.io/role/elb = 1` for Internet-facing ALBs.
- 2 Private Subnets tagged with `kubernetes.io/role/internal-elb = 1` and `karpenter.sh/discovery` for secure worker node placement.
- High-Availability NAT Gateways (1 per AZ) or Single NAT Gateway mode for cost efficiency.
- Dedicated Route Tables and associations for public and private tiers.
- Stateless Network ACLs (NACLs) covering standard HTTP/HTTPS and return ephemeral ports.
- Optional CloudWatch-integrated VPC Flow Logs for traffic auditing and incident response.

## Subnet Tagging Rules for EKS
| Tag Key | Value | Subnet Type | Purpose |
| :--- | :--- | :--- | :--- |
| `kubernetes.io/role/elb` | `1` | Public | AWS Load Balancer Controller uses this to auto-discover subnets for internet-facing ALBs/NLBs. |
| `kubernetes.io/role/internal-elb` | `1` | Private | AWS Load Balancer Controller uses this to auto-discover subnets for internal ALBs/NLBs. |
| `kubernetes.io/cluster/<cluster-name>` | `shared` | Both | Authorizes Kubernetes cluster controllers to discover and provision network resources. |
| `karpenter.sh/discovery` | `<cluster-name>` | Private | Karpenter autoscaler discovers these subnets to launch worker nodes. |

## Network Security: NACLs vs Security Groups
| Feature | Network ACL (NACL) | Security Group (SG) |
| :--- | :--- | :--- |
| **Operates at** | Subnet boundary | Elastic Network Interface (ENI) level |
| **State** | Stateless (return traffic must be explicitly allowed) | Stateful (return traffic automatically permitted) |
| **Rules** | Numbered order of evaluation (allow/deny rules) | Evaluates all rules before deciding (allow only) |
| **Use case** | Coarse-grained perimeter defense (block bad IPs/subnets) | Fine-grained workload defense (microservice isolation) |
