output "vpc_id" {
  description = "The ID of the main VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = module.vpc.public_subnets
}

output "app_subnet_ids" {
  description = "List of IDs of the application subnets (private_subnets from the module)."
  value       = module.vpc.private_subnets
}

output "db_subnet_ids" {
  description = "List of IDs of the database subnets."
  value       = module.vpc.database_subnets
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways."
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "List of public EIPs of the NAT Gateways."
  value       = module.vpc.nat_public_ips
}