terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  backend "s3" {
    bucket  = "tfstate-993938759579"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    profile = "personal"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name,
      "--profile",
      var.profile
    ]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  cluster_name = "${var.cluster_name}_${var.env}"
}

# VPC configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name                   = "eks-vpc"
  cidr                   = "172.16.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  private_subnets        = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets         = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = (var.env != "prod" ? true : false)
  one_nat_gateway_per_az = (var.env != "prod" ? false : true)
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# EKS configuration
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.23.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      capacity_type = "SPOT"
      instance_type = var.default_node_type
    }
  }

  write_kubeconfig = true
  #   config_output_path = "./"

  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_openid_connect_provider" "default" {
  url = module.eks.cluster_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = []
}

# IAM policies configuration
resource "aws_iam_policy" "worker_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${local.cluster_name}"
  description = "AWSLoadBalancerControllerIAMPolicy"

  policy = file("iam-policy.json")
}