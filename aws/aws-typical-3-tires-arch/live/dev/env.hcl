locals {
    aws_region = "ap-southeast-1"
    environment = "dev"

    vpc_cidr_block = "10.0.0.0/16"
    public_subnets_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    app_subnets_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
    db_subnets_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]

    web_instance_type = "t3.micro"
    app_instance_type = "t3.micro"
    db_instance_class = "db.t3.micro"
}