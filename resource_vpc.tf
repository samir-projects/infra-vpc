locals {
    vpc_name = "vpc-${var.username}"
    public_subnet  = "vpc-${var.username}-publicsubnet"
    private_subnet = "vpc-${var.username}-privatesubnet"
    internet_gateway= "igw-${var.username}"
    route_table = "rt-${var.username}"
    security_groups= "SSHSG-${var.username}"
}
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = local.public_subnet
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = local.private_subnet
  }
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
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "test_sg" {
  name   = local.security_groups
  vpc_id = aws_vpc.main.id
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
resource "aws_instance" "test-instance" {
  ami           = "ami-06c8f2ec674c67112"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  key_name = "demokeypair"
  security_groups = [aws_security_group.test_sg.id]

  tags = {
    Name = "Dockerinstance"
  }
}