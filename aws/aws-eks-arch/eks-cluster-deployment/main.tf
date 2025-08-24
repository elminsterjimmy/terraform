provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "random_string" "suffix" {
  length    = 8
  special = false
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name = "eks-vpc"

  cidr = "10.0.0.0/16"
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.8.5"

    cluster_name = var.cluster_name
    cluster_version = "1.29"

    cluster_endpoint_public_access = true
    enable_cluster_creator_admin_permissions = true

    cluster_addons = {
        aws-ebs-csi-driver = {
            service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
        }
    }

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"
        instance_types = ["t3.medium"]
        disk_size = 20
        desired_capacity = 2
        max_capacity = 3
        min_capacity = 1
        additional_tags = {
            Name = "${var.cluster_name}-node-group-${random_string.suffix.result}"
        }
    }

    eks_managed_node_groups = {
        node_group_1 = {
            name = var.node_group_name

            instance_types = ["t3.medium"]

            min_size = 1
            desired_size = 2
            max_size = 3
        }

        node_group_2 = {
            name = "${var.node_group_name}-spot"

            instance_types = ["t3.small"]
            capacity_type = "SPOT"

            min_size = 1
            desired_size = 1
            max_size = 2
        }
    }
}

data "aws_iam_policy" "ebs_csi_driver" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role = true
  role_name   = "eks-ebs-csi-driver-role-${random_string.suffix.result}"
  provider_url = module.eks.cluster_oidc_issuer_url
  role_policy_arns = [data.aws_iam_policy.ebs_csi_driver.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  tags = {
    Name = "eks-ebs-csi-driver-role-${random_string.suffix.result}"
  }
}