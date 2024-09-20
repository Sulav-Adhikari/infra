data "aws_availability_zones" "available" {}

locals {
  public_subnet_start = 10
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.namespace}-${var.stage}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, local.public_subnet_start + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
}


resource "aws_subnet" "private" {
  count             = var.enable_private_net ? var.az_count : 0
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.namespace}-${var.stage}-igw"
  }
}

# Create a new route table for the public subnets, make it route traffic through the Internet gateway to the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  #NOTE:Ignoring manual route changes
  lifecycle {
    ignore_changes = [route]
  }
  tags = {
    Name = "${var.namespace}-${var.stage}-public-rt"
  }
}

# Explicitly associate the newly created route tables to the public subnets (so they don't default to the main route table)
resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id

}


# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "eip" {

  count = var.enable_private_net ? 1 : 0

  domain = "vpc"
  depends_on = [
    aws_internet_gateway.igw
  ]
  tags = {
    Name = "${var.namespace}-${var.stage}-nat-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "gw" {
  # deploy NAT on First subnet
  count         = var.enable_private_net ? 1 : 0
  subnet_id     = element(aws_subnet.public.*.id, 0)
  allocation_id = element(aws_eip.eip.*.id, 0)

  tags = {
    Name = "${var.namespace}-${var.stage}-NAT-Gateway"
  }

  depends_on = [aws_eip.eip]
}


resource "aws_route_table" "private" {

  count = var.enable_private_net ? 1 : 0

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_private_net ? ["1"] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = element(aws_nat_gateway.gw.*.id, 0)
    }
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-private-rt"
  }
}
# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.enable_private_net ? var.az_count : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, 0)
}

# ---- Security Group Start ---


resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-default-sg"
  }

}

# Allow evertthing on local vpc

resource "aws_security_group" "local_allow_all" {
  name        = join("-", [var.namespace, var.stage, "local-allow", "sg"])
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.this.id


  ingress {
    description = "VPC Access"
    protocol    = "tcp"
    from_port   = 1025
    to_port     = 65535
  }

  ingress {
    description = "Allow kubectl access to EKS API"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your public IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [var.namespace, var.stage, "local_allow", "sg"])

  }

}

resource "aws_security_group" "allow_efs" {
  name        = "allow efs for efs"
  description = "Allow efs inbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "efs from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = join("-", [var.namespace, var.stage, "local_nfs", "sg"])
  }
}

#Allow http security group
resource "aws_security_group" "allow_http" {
  name   = "${var.namespace}-${var.stage}-allow-http-sg"
  vpc_id = aws_vpc.this.id

  description = "http Security Group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    "Name" = "${var.namespace}-${var.stage}-allow-http-sg"
  }
}

resource "aws_security_group_rule" "web_access" {
  count             = length(var.http_ports)
  type              = "ingress"
  from_port         = element(var.http_ports, count.index)
  to_port           = element(var.http_ports, count.index)
  protocol          = "tcp"
  cidr_blocks       = var.http_allow_cidrs
  security_group_id = aws_security_group.allow_http.id
  description       = "Allow ${var.namespace} ${var.stage} ${element(var.http_ports, count.index)}"

}

#Allow ssh security group

resource "aws_security_group" "allow_ssh" {
  count       = length(var.ssh_allow_cidrs) > 0 ? 1 : 0
  name        = "${var.namespace}-${var.stage}-allow-ssh-sg"
  vpc_id      = aws_vpc.this.id
  description = aws_vpc.this.id

  ingress {
    description = "SSH Internet Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allow_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.namespace}-${var.stage}-allow-ssh-sg"
  }

}