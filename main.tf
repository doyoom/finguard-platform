module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  azs                 = ["ap-northeast-2a", "ap-northeast-2c"]
  region              = "ap-northeast-2"
}

module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  cluster_name       = "cloudflix-cluster"
  karpenter_role_arn = "arn:aws:iam::123456789012:role/KarpenterControllerRole"
}