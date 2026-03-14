###############################################################################
# EKS Module — Managed Node Group + OIDC + access_entries
###############################################################################

# ── EKS Cluster ──────────────────────────────────────
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = { Name = var.cluster_name }
}

# ── OIDC Provider (IRSA) ────────────────────────────
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# ── Managed Node Group ───────────────────────────────
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = { Name = "${var.cluster_name}-node-group" }
}

# ── EKS Access Entry (노드 역할) ─────────────────────
resource "aws_eks_access_entry" "node" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.node_role_arn
  type          = "EC2_LINUX"
}

# ── CloudWatch Log Group ─────────────────────────────
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  tags = { Name = "${var.cluster_name}-logs" }
}

# ── Node Security Group (for RDS access) ─────────────
data "aws_eks_cluster" "this" {
  name       = aws_eks_cluster.main.name
  depends_on = [aws_eks_node_group.main]
}

data "aws_security_group" "node" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = [aws_eks_cluster.main.name]
  }

  filter {
    name   = "tag:kubernetes.io/cluster/${aws_eks_cluster.main.name}"
    values = ["owned"]
  }

  depends_on = [aws_eks_node_group.main]
}
