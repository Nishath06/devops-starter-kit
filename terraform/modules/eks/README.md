# AWS EKS Module

This module provisions an AWS production EKS v1.33 cluster with managed node groups, security groups, CloudWatch control plane logging, and foundational addons.

## Resources Created
- `aws_eks_cluster`: Managed Kubernetes control plane (v1.33).
- `aws_eks_node_group`: Amazon Linux 2023 (AL2023) worker nodes with autoscaling boundaries.
- `aws_security_group` (Cluster & Node): Fine-grained network filtering.
- `aws_cloudwatch_log_group`: Centralized control plane audit and diagnostic logging.
- `aws_eks_addon`:
  - `vpc-cni`
  - `kube-proxy`
  - `coredns`
  - `eks-pod-identity-agent`
  - `aws-ebs-csi-driver`

## Day 2 GitOps & Addon Readiness
This module outputs the necessary endpoint and security IDs required by downstream GitOps tools:
- **ArgoCD**: Authenticates to `cluster_endpoint` via IAM OIDC.
- **AWS Load Balancer Controller**: Deployed in private subnets, binds to `node_security_group_id`.
- **Metrics Server / Prometheus**: Scrapes metrics across nodes via ports 10250 and 443.
- **Karpenter**: Discovers nodes via `karpenter.sh/discovery` tag on node security group and subnets.
