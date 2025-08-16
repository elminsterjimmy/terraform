include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  app_name = "app"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "vpc-12345"
    public_subnet_ids = ["subnet-123", "subnet-456"]
    app_subnet_ids    = ["subnet-789", "subnet-abc"]
  }
}

terraform {
  source = "../../../modules/app"
}

inputs = {
  environment       = local.env_vars.locals.environment
  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  app_subnet_ids    = dependency.vpc.outputs.app_subnet_ids
  app_name          = local.app_name
  web_instance_type = local.env_vars.locals.web_instance_type
  app_instance_type = local.env_vars.locals.app_instance_type
}