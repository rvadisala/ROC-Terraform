#######
# VPC #
#######

resource "aws_vpc" "roc" {
  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  enable_classiclink              = var.enable_classiclink
  enable_classiclink_dns_support  = var.enable_classiclink_dns_support

  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

##################
# Publiс Subnets #
##################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.roc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, var.public_subnet_tags, map("Name", format("%s-subnet-public-%s", var.name, element(var.azs, count.index))))
}

###################
# Private Subnets #
###################

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.roc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, var.private_subnet_tags, map("Name", format("%s-subnet-private-%s", var.name, element(var.azs, count.index))))
}

################
# Data Subnets #
################

resource "aws_subnet" "data" {
  count = length(var.data_subnets)

  vpc_id            = aws_vpc.roc.id
  cidr_block        = var.data_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, var.data_subnet_tags, map("Name", format("%s-subnet-data-%s", var.name, element(var.azs, count.index))))
}

####################
# Internet Gateway #
####################

resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.roc.id

  tags = merge(var.tags, map("Name", format("%s-igw", var.name)))
}

#################
# Publiс routes #
#################

resource "aws_route_table" "public_route" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id           = aws_vpc.roc.id
  depends_on       = [ aws_internet_gateway.igw ]
# propagating_vgws = ["${var.public_propagating_vgws}"]

  tags = merge(var.tags, map("Name", format("%s-rt-public", var.name)))
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = element(aws_route_table.public_route.*.id,count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.igw.*.id,count.index)
}

##################
# Private routes #
##################

resource "aws_route_table" "private_route" {
  count = length(var.azs)

  vpc_id           = aws_vpc.roc.id
#  propagating_vgws = ["${var.private_propagating_vgws}"]

  tags = merge(var.tags, map("Name", format("%s-rt-private-%s", var.name, element(var.azs, count.index))))
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.azs) : 0

  route_table_id         =  element(aws_route_table.private_route.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
}

###############
# NAT Gateway #
###############

resource "aws_eip" "natip" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  allocation_id = element(aws_eip.natip.*.id, (var.single_nat_gateway ? 0 : count.index))
  subnet_id     = element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))

  depends_on = [ aws_internet_gateway.igw ]
}

###########################
# Route Table Association #
###########################

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_route.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
}

resource "aws_route_table_association" "data" {
  count = length(var.data_subnets)

  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
}