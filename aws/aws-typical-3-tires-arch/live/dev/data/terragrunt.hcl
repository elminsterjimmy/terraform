include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"
    db_subnet_ids = ["subnet-78901234", "subnet-89012345"]
  }
}

dependency "app" {
  config_path = "../app"
  mock_outputs = {
    app_security_group_id = "sg-45678901"
  }
}

terraform {
  source = "../../../modules/data"
}

inputs = {
  vpc_id                = dependency.vpc.outputs.vpc_id
  db_subnet_ids         = dependency.vpc.outputs.db_subnet_ids
  app_security_group_id = dependency.app.outputs.app_security_group_id
  environment           = local.env_vars.locals.environment
  db_instance_class     = local.env_vars.locals.db_instance_class

  // NOTE: Secrets should be managed with a secrets manager like AWS Secrets Manager, not in plain text.
  db_username           = "admin" // Replace with a secure method to manage secrets
  db_password           = "password123" // Replace with a secure method to manage secrets
}