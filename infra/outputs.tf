# ── VPC ──────────────────────────────────────────────
output "vpc_id" {
  value = module.vpc.vpc_id
}

# ── EKS ──────────────────────────────────────────────
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# ── ECR ──────────────────────────────────────────────
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

# ── RDS ──────────────────────────────────────────────
output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_db_name" {
  value = module.rds.db_name
}
