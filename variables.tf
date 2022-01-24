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
  default     = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
}

variable "public_subnets" {
  type        = list
  description = "A list of public subnets inside the VPC."
  default     = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = { }
}

variable "private_subnets" {
  type        = list
  description = "A list of private subnets inside the VPC."
  default     = [ "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24" ]
}

variable "private_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = { }
}

variable "data_subnets" {
  type        = list
  description = "A list of data subnets"
  default     = [ "10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24" ]
}

variable "data_subnet_tags" {
  description = "Additional tags for the data subnets"
  default     = { }
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = { type = "list" }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = { 
                Terraform = "true"
                Environment = "prod"
  }
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = false
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
  default     = false
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
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "should be true if you want to provision an DynamoDB endpoint to the VPC"
  default     = false
}

variable "enable_ssm_endpoint" {
  description = "Should be true if you want to provision an SSM endpoint to the VPC"
  default     = false
}
