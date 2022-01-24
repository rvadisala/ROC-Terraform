output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "data_subnets" {
  value = aws_subnet.data.*.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "vpc_id" {
  value = aws_vpc.roc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.roc.cidr_block
}

output "public_route_table_ids" {
  value = aws_route_table.public_route.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.private_route.*.id
}

output "default_security_group_id" {
  value = aws_vpc.roc.default_security_group_id
}

output "nat_eips" {
  value = aws_eip.natip.*.id
}

output "nat_eips_public_ips" {
  value = aws_eip.natip.*.public_ip
}

output "natgw_ids" {
  value = aws_nat_gateway.natgw.*.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.*.id
}

output "default_network_acl_id" {
  value = aws_vpc.roc.default_network_acl_id
}

output "vpc_endpoint_s3_id" {
  value = aws_vpc_endpoint.s3.*.id
}

output "vpc_endpoint_dynamodb_id" {
  value = aws_vpc_endpoint.dynamodb.*.id
}