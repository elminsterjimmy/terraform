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
  description = "List of CIDR blocks for application subnets."
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

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_subnet" "app" {
  count = length(var.app_subnets_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnets_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.environment}-app-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_subnet" "db" {
  count = length(var.db_subnets_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnets_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.environment}-db-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets_cidrs)

  tags = {
    Name        = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_subnets_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  count = length(var.app_subnets_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name        = "${var.environment}-private-app-route-table-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.app)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

resource "aws_route_table" "private_db" {
  count = length(var.db_subnets_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name        = "${var.environment}-private-db-route-table-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.db)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id

}