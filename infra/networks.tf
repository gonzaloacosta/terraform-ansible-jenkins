resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = "10.3.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${local.preffix}-jenins-master-vpc" })
}

resource "aws_vpc" "vpc_slaves" {
  provider             = aws.region_slaves
  cidr_block           = "20.3.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${local.preffix}-jenkins-slaves-vpcs" })
}

resource "aws_internet_gateway" "igw_master" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  tags     = merge(local.tags, { Name = "${local.preffix}-jenkins-master-igw" })
}

resource "aws_internet_gateway" "igw_slaves" {
  provider = aws.region_slaves
  vpc_id   = aws_vpc.vpc_slaves.id
  tags     = merge(local.tags, { Name = "${local.preffix}-jenkins-slaves-igw" })
}

data "aws_availability_zones" "az_master" {
  provider = aws.region_master
  state    = "available"
}

data "aws_availability_zones" "az_slaves" {
  provider = aws.region_slaves
  state    = "available"
}

resource "aws_subnet" "master_subnet_1" {
  provider          = aws.region_master
  availability_zone = element(data.aws_availability_zones.az_master.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.3.1.0/24"
  tags              = merge(local.tags, { Name = "${local.preffix}-jenkins-master-subnet" })
}

resource "aws_subnet" "master_subnet_2" {
  provider          = aws.region_master
  availability_zone = element(data.aws_availability_zones.az_master.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.3.2.0/24"
  tags              = merge(local.tags, { Name = "${local.preffix}-jenkins-master-subnet" })
}

resource "aws_subnet" "slaves_subnet_1" {
  provider          = aws.region_slaves
  availability_zone = element(data.aws_availability_zones.az_slaves.names, 0)
  vpc_id            = aws_vpc.vpc_slaves.id
  cidr_block        = "20.3.1.0/24"
  tags              = merge(local.tags, { Name = "${local.preffix}-jenkins-master-subnet" })
}

# Iniciate VPC Peering master to slaves vpc
resource "aws_vpc_peering_connection" "vpc_master_vpc_slaves" {
  provider    = aws.region_master
  peer_vpc_id = aws_vpc.vpc_slaves.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.jenkins_slaves_region
  tags        = merge(local.tags, { Name = "${local.preffix}-jenkins-master-peer-slaves" })
}

# Accepting VPC Peering
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region_slaves
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_master_vpc_slaves.id
  auto_accept               = true
}

# Create route table in master_region
resource "aws_route_table" "internet_route_master" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_master.id
  }
  route {
    cidr_block                = "20.3.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_master_vpc_slaves.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = merge(local.tags, { Name = "${local.preffix}-jenkins-master-rt" })
}

resource "aws_main_route_table_association" "set_master_default_rt_assoc" {
  provider       = aws.region_master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route_master.id
}

# Create route table in slaves region
resource "aws_route_table" "internet_route_slaves" {
  provider = aws.region_slaves
  vpc_id   = aws_vpc.vpc_slaves.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_slaves.id
  }
  route {
    cidr_block                = "10.3.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_master_vpc_slaves.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = merge(local.tags, { Name = "${local.preffix}-jenkins-slaves-rt" })
}

resource "aws_main_route_table_association" "set_slaves_default_rt_assoc" {
  provider       = aws.region_slaves
  vpc_id         = aws_vpc.vpc_slaves.id
  route_table_id = aws_route_table.internet_route_slaves.id
}
