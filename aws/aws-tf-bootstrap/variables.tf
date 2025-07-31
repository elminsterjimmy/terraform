variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "aws_profile" {
  description = "The AWS CLI profile to use for authentication."
  type        = string
}

variable "s3_terraform_state_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state files."
  type        = string
}

variable "dynamodb_terraform_state_lock_table" {
  description = "The name of the DynamoDB table for state locking."
  type        = string
}