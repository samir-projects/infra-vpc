locals {
  vpc_name         = "vpc-${var.username}"
  public_subnet1   = "vpc-${var.username}-publicsubnet1"
  public_subnet2   = "vpc-${var.username}-publicsubnet2"
  private_subnet1  = "vpc-${var.username}-privatesubnet1"
  private_subnet2  = "vpc-${var.username}-privatesubnet2"
  internet_gateway = "igw-${var.username}"
  route_table      = "rt-${var.username}"
  security_groups  = "SSHSG-${var.username}"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_subnet" "public-subnets" {
  count             = length(var.subnet_cidrs_public)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs_public[count.index]
  availability_zone = var.availability_zones[count.index]
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

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = local.route_table
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.subnet_cidrs_public)
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "test_sg" {
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