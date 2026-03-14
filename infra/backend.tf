# S3 backend for remote state (주석 해제 후 사용)
# terraform {
#   backend "s3" {
#     bucket         = "finguard-terraform-state"
#     key            = "infra/terraform.tfstate"
#     region         = "ap-northeast-2"
#     dynamodb_table = "finguard-terraform-lock"
#     encrypt        = true
#   }
# }
