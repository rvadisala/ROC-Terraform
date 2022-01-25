# VPC Endpoint for S3 #
data "aws_vpc_endpoint_service" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id       = aws_vpc.roc.id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.enable_s3_endpoint ? length(var.private_subnets) : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private_route.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.enable_s3_endpoint ? length(var.public_subnets) : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.public_route.*.id, count.index)
}



# VPC Endpoint for DynamoDB #


data "aws_vpc_endpoint_service" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id = aws_vpc.roc.id

  service_name = data.aws_vpc_endpoint_service.dynamodb[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = var.enable_dynamodb_endpoint ? length(var.private_subnets) : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.private_route.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = var.enable_dynamodb_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.public_route.*.id, count.index)
}
