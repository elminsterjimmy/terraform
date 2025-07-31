variable "aws_region" {
  description = "The AWS region where the VPC will be created."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "app_subnets_cidrs" {
  description = "List of CIDR blocks for application subnets (will map to 'private_subnets')."
  type        = list(string)
}

variable "db_subnets_cidrs" {
  description = "List of CIDR blocks for database subnets."
  type        = list(string)
}

variable "environment" {
  description = "The environment for which the VPC is being created (e.g., dev, staging, prod)."
  type        = string
}

# No need for data "aws_availability_zones" "available" explicitly here,
# as the module can fetch AZs based on the number of subnets or you can pass them.
# However, if you want precise control over which AZs are used for subnets,
# you might still keep this data source and pass its output to the 'azs' variable of the module.
# Let's keep it for explicit AZ control.
data "aws_availability_zones" "available" {} # Still useful to get AZ names