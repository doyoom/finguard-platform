module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  fargate_profiles = {
    default = {
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  enable_karpenter = true

  access_entries = {
    karpenter = {
      kubernetes_groups = ["system:masters"]
      principal_arn     = var.karpenter_role_arn
      type              = "STANDARD"
    }
  }
}