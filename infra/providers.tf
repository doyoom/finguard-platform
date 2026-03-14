provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "finguard"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
