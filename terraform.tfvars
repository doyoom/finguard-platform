project_name = "cloudflix"
region       = "ap-northeast-2"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
azs                  = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

cluster_name = "cloudflix-cluster"