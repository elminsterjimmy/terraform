locals {
    aws_region = "ap-southeast-2"
    environment = "prod"

    vpc_cidr_block = "10.1.0.0/16"
    public_subnets_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
    app_subnets_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
    db_subnets_cidrs = ["10.1.5.0/24", "10.1.6.0/24"]

    web_instance_type = "t3.small"
    app_instance_type = "t3.medium"
    db_instance_class = "db.t3.medium"
}