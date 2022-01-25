resource "aws_customer_gateway" "cgw" {
  for_each = var.customer_gateways

  bgp_asn    = each.value["bgp_asn"]
  ip_address = each.value["ip_address"]
  type       = "ipsec.1"

    tags = merge(var.tags, map("Name", format("%s-%s",var.name,each.key)))
}