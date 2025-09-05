locals {
  vpc_name            = "vpc-${var.username}"
  public_subnet1      = "vpc-${var.username}-publicsubnet1"
  public_subnet2      = "vpc-${var.username}-publicsubnet2"
  private_subnet1     = "vpc-${var.username}-privatesubnet1"
  private_subnet2     = "vpc-${var.username}-privatesubnet2"
  internet_gateway    = "igw-${var.username}"
  private_route_table = "pvt-rt-${var.username}"
  public_route_table  = "pub-rt-${var.username}"
  security_groups     = "SSH-SG-${var.username}"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_subnet" "public-subnets" {
  count                   = length(var.subnet_cidrs_public)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs_public[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnets" {
  count             = length(var.subnet_cidrs_private)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = var.availability_zones[count.index]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.internet_gateway
  }
}

resource "aws_eip" "eip-nat-gateway" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip-nat-gateway.id
  subnet_id     = aws_subnet.public-subnets[1].id

  tags = {
    Name = "Natgateway"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.subnet_cidrs_public)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.subnet_cidrs_private)
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_security_group" "ssh-sg" {
  name        = local.security_groups
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH access to the host"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.security_groups
  }
}