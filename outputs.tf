output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "karpenter_role_arn" {
  value = module.eks.karpenter_controller_role_arn
}

output "karpenter_instance_profile" {
  value = module.eks.karpenter_node_instance_profile
}