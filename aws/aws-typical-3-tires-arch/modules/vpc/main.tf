# main.tf (or vpc.tf)

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.0.0" 

  # --- Core VPC Configuration ---
  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr_block

  # Use the data source to get AZs, then ensure we only use as many as we have subnets.
  # The module will distribute subnets across these AZs.
  # Ensure the number of AZs you list here is at least equal to the max number of subnets you provide for any type.
  # For example, if you have 3 public subnets, you need at least 3 AZs listed here.
  # It's safest to just list all available AZs and let the module pick for each subnet.
  azs = data.aws_availability_zones.available.names

  # Enable DNS Support and Hostnames
  enable_dns_support   = true
  enable_dns_hostnames = true

  # --- Subnet Configuration ---
  # Public Subnets (will be mapped to `public_subnets`)
  public_subnets = var.public_subnets_cidrs
  # Ensure public subnets map public IPs (this module variable does that)
  map_public_ip_on_launch = true

  # Application Subnets (will be mapped to `private_subnets` in this module)
  private_subnets = var.app_subnets_cidrs

  # Database Subnets
  database_subnets = var.db_subnets_cidrs

  # --- NAT Gateway Configuration ---
  enable_nat_gateway = true
  # Set to 'false' if you want one NAT Gateway per AZ (which aligns with your previous code's count logic)
  single_nat_gateway = false
  
  # If you *explicitly* want to re-use EIPs managed *outside* this module (e.g., your old `aws_eip.nat` resource)
  # then you would declare `aws_eip` resources outside this module and pass their IDs.
  # For simplicity, let the module create them by default.
  # The module will create EIPs for the NAT Gateways automatically if `reuse_nat_ips` is false (default).
  # If you need to keep static EIPs across deploys, you'd define them outside like your original `aws_eip.nat`
  # and then pass `reuse_nat_ips = true` and `external_nat_ip_ids = [aws_eip.nat[0].id, aws_eip.nat[1].id]`
  # However, it's often simpler to let the module manage them completely.

  # --- Route Table Configuration (managed by the module implicitly) ---
  # The module automatically creates and associates route tables for public, private, and database subnets.
  # You don't need `aws_route_table` or `aws_route_table_association` resources anymore for these.

  # Ensure DB subnets have outbound internet access via NAT Gateway (matches your previous code)
  create_database_nat_gateway_route = true

  # --- Tags ---
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}