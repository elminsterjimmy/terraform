variable "aws_region" {
  description = "The AWS region where the VPC will be created."
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "eks-cluster"
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
  default     = "node-group"
}