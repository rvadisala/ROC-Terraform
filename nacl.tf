# Default Network ACLs
#######################

resource "aws_default_network_acl" "netacl" {
  count = var.manage_default_network_acl ? 1 : 0

  default_network_acl_id = element(concat(aws_vpc.roc.*.default_network_acl_id, [""]), 0)

  dynamic "ingress" {
    for_each = var.default_network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.default_network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = merge(
    {
      "Name" = format("%s", var.default_network_acl_name)
    },
    var.tags,
    var.default_network_acl_tags,
  )

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

# Public Network ACLs
########################

resource "aws_network_acl" "public" {
  count = var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.roc.*.id, [""]), 0)
  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
    var.public_acl_tags,
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

# Private Network ACLs
#######################
resource "aws_network_acl" "private" {
  count = var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.roc.*.id, [""]), 0)
  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}", var.name)
    },
    var.tags,
    var.private_acl_tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? length(var.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}


# Data Network ACLs
#######################

resource "aws_network_acl" "data" {
  count = var.data_dedicated_network_acl && length(var.data_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.roc.*.id, [""]), 0)
  subnet_ids = aws_subnet.data.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.data_subnet_suffix}", var.name)
    },
    var.tags,
    var.data_acl_tags,
  )
}

resource "aws_network_acl_rule" "data_inbound" {
  count = var.data_dedicated_network_acl && length(var.data_subnets) > 0 ? length(var.data_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.data[0].id

  egress          = false
  rule_number     = var.data_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.data_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.data_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.data_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.data_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.data_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.data_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.data_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.data_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "data_outbound" {
  count = var.data_dedicated_network_acl && length(var.data_subnets) > 0 ? length(var.data_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.data[0].id

  egress          = true
  rule_number     = var.data_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.data_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.data_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.data_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.data_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.data_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.data_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.data_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.data_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}
