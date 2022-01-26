variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "roc-vpc"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "public_subnets" {
  type        = list(any)
  description = "A list of public subnets inside the VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "enable_ipv6" {
  description = "IPV6 support"
  default = false
}

variable "private_subnets" {
  type        = list(any)
  description = "A list of private subnets inside the VPC."
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "private_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "data_subnets" {
  type        = list(any)
  description = "A list of data subnets"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "data_subnet_tags" {
  description = "Additional tags for the data subnets"
  default     = {}
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = { type = "list" }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {
    Terraform   = "true"
    Environment = "prod"
  }
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block"
  default     = false
}

variable "enable_classiclink" {
  description = "should be true if you want to use ClassicLink within the VPC"
  default     = false
}

variable "enable_classiclink_dns_support" {
  description = "should be true if you want to use private DNS within the classiclinks"
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "enable_nat_gateway" {
  description = "should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

########################################
##### VPN VARIABLES DECLARATION ########
########################################

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = true
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  default     = {}
}

variable "vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  default     = ""
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  default     = false
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  default     = false
}


#################################################
##### VPC ENDPOINT VARIABLES DECLARATION ########
#################################################

variable "enable_s3_endpoint" {
  description = "should be true if you want to provision an S3 endpoint to the VPC"
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "should be true if you want to provision an DynamoDB endpoint to the VPC"
  default     = true
}


#################################################
#####  Network ACL VARIABLES DECLARATION ########
#################################################

variable "manage_default_network_acl" {
  description = "Should be true to adopt and manage Default Network ACL"
  default     = false
}

variable "default_network_acl_name" {
  description = "Name to be used on the Default Network ACL"
  default     = ""
}

variable "default_network_acl_tags" {
  description = "Additional tags for the Default Network ACL"
  default     = {}
}

variable "public_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  default     = {}
}

variable "private_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  default     = {}
}

variable "data_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  default     = {}
}

variable "nat_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  default     = {}
}

variable "public_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for public subnets"
  default     = false
}

variable "private_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for private subnets"
  default     = false
}

variable "data_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for private subnets"
  default     = false
}

variable "nat_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for nat subnets"
  default     = false
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  default     = "private"
}

variable "data_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  default     = "private"
}

variable "default_network_acl_ingress" {
  description = "List of maps of ingress rules to set on the Default Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "default_network_acl_egress" {
  description = "List of maps of egress rules to set on the Default Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "data_inbound_acl_rules" {
  description = "Data subnets inbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "data_outbound_acl_rules" {
  description = "Data subnets outbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}


variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  type        = map(map(any))
  default     = {}
}

variable "customer_gateway_tags" {
  description = "Additional tags for the Customer Gateway"
  type        = map(string)
  default     = {}
}

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create IAM role for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination. Can be s3 or cloud-watch-logs."
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_log_log_format" {
  description = "The fields to include in the flow log record, in the order in which they should appear."
  type        = string
  default     = null
}

variable "flow_log_destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "Specifies the name prefix of CloudWatch Log Group for VPC flow logs."
  type        = string
  default     = "/aws/vpc-flow-log/"
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = number
  default     = null
}

variable "flow_log_cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data for VPC flow logs."
  type        = string
  default     = null
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = number
  default     = 600
}

variable "vpc_flow_log_tags" {
  description = "Additional tags for the VPC Flow Logs"
  type        = map(string)
  default     = {}
}

variable "vpc_flow_log_permissions_boundary" {
  description = "The ARN of the Permissions Boundary for the VPC Flow Log IAM Role"
  type        = string
  default     = null
}
