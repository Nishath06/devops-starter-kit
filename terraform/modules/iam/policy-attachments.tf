# =============================================================================
# modules/iam/policy-attachments.tf — AWS Managed Policy Attachments
# =============================================================================
# Attaches the standard AWS-managed policies required by EKS control plane
# and worker node EC2 instances.
# =============================================================================

# -----------------------------------------------------------------------------
# Cluster Role Attachments
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# -----------------------------------------------------------------------------
# Node Group Role Attachments
# -----------------------------------------------------------------------------
# 1. AmazonEKSWorkerNodePolicy: Allows nodes to connect to EKS control plane
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# 2. AmazonEC2ContainerRegistryReadOnly: Allows nodes to pull images from ECR
resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# 3. AmazonEKS_CNI_Policy: Grants VPC CNI plugin rights to allocate and assign IP addresses
resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# 4. CloudWatchAgentServerPolicy: Grants worker nodes permission to emit CloudWatch metrics & logs
resource "aws_iam_role_policy_attachment" "node_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.node.name
}
