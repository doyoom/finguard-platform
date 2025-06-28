variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "private_subnet_cidrs" {
  type        = list(string)
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}
