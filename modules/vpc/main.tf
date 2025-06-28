provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudflix-vpc"
    Type = "Main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudflix-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = { for i, cidr in var.public_subnet_cidrs : "public-${i}" => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.azs[tonumber(regex("[0-9]+", each.key))]
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudflix-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for i, cidr in var.private_subnet_cidrs : "private-${i}" => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(regex("[0-9]+", each.key))]

  tags = {
    Name = "cloudflix-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "cloudflix-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "cloudflix-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public-0"].id

  tags = {
    Name = "cloudflix-nat"
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "cloudflix-private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for rt in aws_route_table.private : rt.id
  ]

  tags = {
    Name = "cloudflix-s3-endpoint"
  }
}
