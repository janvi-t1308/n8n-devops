##########################################################
# networking.tf
#
# Creates the networking infrastructure for the project.
#
# Resources managed in this file:
# - VPC
# - Subnets
# - Internet Gateway
# - NAT Gateway
# - Route Tables
##########################################################

##########################################################
# Main VPC
#
# This VPC provides an isolated network for all project
# resources. A /16 CIDR is chosen to allow enough address
# space for multiple public and private subnets.
##########################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  #enables dns resolution within the VPC
  enable_dns_support = true

  #assign dns hostnames to instances that receives public ip addresses
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-vpc"
  }
}

##########################################################
# Internet Gateway
#
# Connects the VPC to the public Internet.
# Public subnets will use this gateway through
# their Route Table.
##########################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-IGW"
  }
}

##########################################################
# Public Route Table
#
# Defines routing for all public subnets.
# Internet-bound traffic is sent to the Internet Gateway.
##########################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route for all traffic destined outside the VPC.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.project_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_A.id
}

resource "aws_route_table_association" "public_b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_B.id
}


##########################################################
# Public Subnet
#
# Used for internet-facing resources such as:
# - Application Load Balancer
# - NAT Gateway
#
# Instances launched here automatically receive
# public IP addresses.
##########################################################

resource "aws_subnet" "public_A" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_a_cidr_range
  availability_zone = "ap-south-1a"

  # Automatically assigns a public IPv4 address to instances launched in this subnet.
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public-subnet-a"
  }

}

resource "aws_subnet" "public_B" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_b_cidr_range
  availability_zone = "ap-south-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public-subnet-b"
  }
}

##########################################################
# Elastic IP for NAT Gateway
#
# Provides a stable public IP address for the NAT Gateway.
# External services can whitelist this IP if required.
##########################################################

resource "aws_eip" "nat_eip" {

  # tells AWS this Elastic IP is for a VPC resource.
  domain = "vpc"

  tags = {
    Name = "${local.project_name}-nat-eip"
  }
}

##########################################################
# NAT Gateway - Availability Zone A
#
# Allows resources in private subnets to initiate outbound
# Internet connections while remaining inaccessible from
# the public Internet.
##########################################################

resource "aws_nat_gateway" "nat" {

  # This attaches the Elastic IP to the NAT Gateway.
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_A.id

  tags = {
    Name = "${local.project_name}-nat-gateway"
  }
}

##########################################################
# Private Route Table
#
# Routes Internet-bound traffic from private subnets
# through the NAT Gateway.
##########################################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${local.project_name}-private_routetable"
  }
}

##########################################################
# Private Subnet
#
# Hosts internal application resources that should not
# receive public IP addresses.
##########################################################

resource "aws_subnet" "private_A" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr_range
  availability_zone = "ap-south-1a"

  # Instances launched here receive only private IPs.
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project_name}-private-subnet-A"
  }
}

resource "aws_subnet" "private_B" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b_cidr_range
  availability_zone = "ap-south-1b"

  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project_name}-private-subnet-B"
  }
}

##########################################################
# Private Route Table Associations
#
# Associates the private subnets with the private
# Route Table so outbound Internet traffic is routed
# through the NAT Gateway.
##########################################################

resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_A.id
}

resource "aws_route_table_association" "private_b" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_B.id
}
