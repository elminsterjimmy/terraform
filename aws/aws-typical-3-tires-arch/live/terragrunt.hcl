locals {
aws_region           = "ap-southeast-1"
  tf_state_bucket_name = "elmnst-global-terraform-state-bucket"
  tf_state_lock_table  = "terraform-locks"
  aws_profile          = "devops-admin"
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "${local.aws_profile}"
}
EOF
}

# Generate versions
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws      = "~> 5.92"
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = local.tf_state_bucket_name
    key            = "live/global/${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = local.tf_state_lock_table
    encrypt        = true
  }
  generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
}

inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals,
)