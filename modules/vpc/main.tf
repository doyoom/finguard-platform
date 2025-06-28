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

#public subnets
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
  for_each = aws_subnet.private

  domain = "vpc"

  tags = {
    Name = "cloudflix-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.private

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = values(aws_subnet.public)[0].id  # 모든 NAT을 첫 번째 public subnet에 둠

  tags = {
    Name = "cloudflix-nat-${each.key}"
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
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