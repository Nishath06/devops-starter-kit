# AWS IAM Module for EKS

This module provisions dedicated IAM roles and the OpenID Connect (OIDC) identity provider necessary to implement **IAM Roles for Service Accounts (IRSA)** for Amazon EKS.

## Resources Created
- **EKS Cluster Control Plane Role**: Assumed by `eks.amazonaws.com` with `AmazonEKSClusterPolicy`.
- **EKS Managed Node Group Role**: Assumed by `ec2.amazonaws.com` with:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonEKS_CNI_Policy`
  - `CloudWatchAgentServerPolicy`
- **IAM OIDC Provider**: Configured with `sts.amazonaws.com` client ID and SHA-1 root certificate thumbprint.

## Understanding IRSA (IAM Roles for Service Accounts)
Historically, giving pods AWS access required either:
1. Attaching broad policies to the EC2 Node Instance Profile (violates least privilege; any pod on that node inherits all permissions).
2. Storing long-lived IAM Access Keys in Kubernetes Secrets (security risk, rotation overhead).

**IRSA solves this**:
```
Pod (with ServiceAccount) -> Injected Web Identity Token -> STS:AssumeRoleWithWebIdentity -> Temporary Scoped Credentials
```
When creating IAM roles for future controllers (AWS Load Balancer Controller, ExternalDNS, Cert-Manager, Karpenter), use this trust policy condition:
```json
"Condition": {
  "StringEquals": {
    "<OIDC_PROVIDER_URL>:sub": "system:serviceaccount:<namespace>:<serviceaccount-name>",
    "<OIDC_PROVIDER_URL>:aud": "sts.amazonaws.com"
  }
}
```
