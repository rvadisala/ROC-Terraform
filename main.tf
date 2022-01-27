resource "aws_vpc" "roc" {
  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support

  tags = merge(var.tags, tomap({"Name" = format("%s", var.name)}))
}

# Public subnet
################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                          = aws_vpc.roc.id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = var.map_public_ip_on_launch
 
  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.roc.ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null
  
  tags = merge(var.tags, var.public_subnet_tags, tomap({"Name"= format("%s-subnet-public-%s", var.name, element(var.azs, count.index))}))
}

# Private subnet
################

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.roc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  
  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.roc.ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(var.tags, var.private_subnet_tags, tomap({"Name"= format("%s-subnet-private-%s", var.name, element(var.azs, count.index))}))
}

resource "aws_subnet" "data" {
  count = length(var.data_subnets)

  vpc_id            = aws_vpc.roc.id
  cidr_block        = var.data_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  
  assign_ipv6_address_on_creation = var.data_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.data_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block = var.enable_ipv6 && length(var.data_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.roc.ipv6_cidr_block, 8, var.data_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(var.tags, var.data_subnet_tags, tomap({ "Name" = format("%s-subnet-data-%s", var.name, element(var.azs, count.index))}))
}

# Internet Gateway
###################

resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  depends_on = [aws_vpc.roc]
  vpc_id = aws_vpc.roc.id

  tags = merge(var.tags, tomap({ "Name" = format("%s-igw", var.name)}))
}

resource "aws_egress_only_internet_gateway" "egress_igw" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  depends_on = [aws_vpc.roc]
  vpc_id = aws_vpc.roc.id

}

# Publiс routes
################

resource "aws_route_table" "public_route" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id     = aws_vpc.roc.id
  depends_on = [aws_internet_gateway.igw]

  # propagating_vgws = ["${var.public_propagating_vgws}"]

  tags = merge(var.tags, tomap({ "Name" = format("%s-rt-public", var.name)}))
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table.public_route,
  ]
  route_table_id         = element(aws_route_table.public_route.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.igw.*.id, count.index)

    timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.enable_ipv6 && length(var.public_subnets) > 0 ? 1 : 0

  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table.public_route,
  ]

  route_table_id              = element(aws_route_table.public_route.*.id, count.index)
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = element(aws_internet_gateway.igw.*.id, count.index)
}

# Private routes
#################

resource "aws_route_table" "private_route" {
  count = length(var.azs)

  depends_on = [aws_vpc.roc]

  vpc_id = aws_vpc.roc.id

  tags = merge(var.tags, tomap({ "Name" = format("%s-rt-private-%s", var.name, element(var.azs, count.index))}))

  lifecycle { 
    ignore_changes = [propagating_vgws]
  }
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.azs) : 0

  depends_on = [
    aws_nat_gateway.natgw,
    aws_route_table.private_route,
  ]

  route_table_id         = element(aws_route_table.private_route.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)

  timeouts {
    create = "5m"
  }

}

resource "aws_route" "private_ipv6_egress" {
  count = var.enable_ipv6 ? length(var.private_subnets) : 0

  depends_on = [
    aws_egress_only_internet_gateway.egress_igw,
    aws_route_table.private_route,
  ]

  route_table_id              = element(aws_route_table.private_route.*.id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = element(aws_egress_only_internet_gateway.egress_igw.*.id, 0)
}


# AWS EIP & NAT GATEWAY
########################

resource "aws_eip" "natip" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  vpc = true

  tags = merge(var.tags, tomap({ "Name" = format("%s-%s",var.name, element(var.azs, var.single_nat_gateway ? 0 : count.index))}))
}

resource "aws_nat_gateway" "natgw" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  depends_on = [
    aws_internet_gateway.igw,
    aws_eip.natip,
  ]

  allocation_id = element(aws_eip.natip.*.id, (var.single_nat_gateway ? 0 : count.index))
  subnet_id     = element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))

}

# Route table association
##########################

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_route.*.id, count.index)
#  route_table_id = aws_route_table.public[0].id

}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, var.single_nat_gateway ? 0 : count.index,)
}

resource "aws_route_table_association" "data" {
  count = length(var.data_subnets)

  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)

}
