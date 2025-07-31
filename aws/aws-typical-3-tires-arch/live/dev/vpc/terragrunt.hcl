include "root" {
    path = find_in_parent_folders()
}

locals {
    env_ars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
    source = "../../../modules/vpc"
}

inputs = {
    vpc_cidr_block = local.env_ars.locals.vpc_cidr_block
    public_subnets_cidrs = local.env_ars.locals.public_subnets_cidrs
    app_subnets_cidrs = local.env_ars.locals.app_subnets_cidrs
    db_subnets_cidrs = local.env_ars.locals.db_subnets_cidrs
}