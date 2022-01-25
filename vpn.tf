resource "aws_vpn_gateway" "vgw" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.roc.id

  tags = merge(var.tags, var.vpn_gateway_tags, map("Name", format("%s", var.name)))

}

resource "aws_vpn_gateway_attachment" "vgwa" {
  count = var.vpn_gateway_id != "" ? 1 : 0

  vpc_id         = aws_vpc.roc.id
  vpn_gateway_id = var.vpn_gateway_id
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = var.propagate_public_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? 1 : 0

  route_table_id = element(aws_route_table.public_route.*.id, count.index)
  vpn_gateway_id = element(concat(aws_vpn_gateway.vgw.*.id, aws_vpn_gateway_attachment.vgwa.*.vpn_gateway_id), count.index)
}


resource "aws_vpn_gateway_route_propagation" "private" {
  count = var.propagate_private_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? length(var.private_subnets) : 0

  route_table_id = element(aws_route_table.private_route.*.id, count.index)
  vpn_gateway_id = element(concat(aws_vpn_gateway.vgw.*.id, aws_vpn_gateway_attachment.vgwa.*.vpn_gateway_id), count.index)
}
