###############################################################################
# FinGuard — Root Module
###############################################################################

# ── IAM ──────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  cluster_name = var.cluster_name
}

# ── VPC ──────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

# ── EKS ──────────────────────────────────────────────
module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_role_arn       = module.iam.eks_node_role_arn
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

# ── ECR ──────────────────────────────────────────────
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

# ── RDS ──────────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
  eks_node_sg_id     = module.eks.node_security_group_id
}
