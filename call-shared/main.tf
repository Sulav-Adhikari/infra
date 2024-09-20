locals {
  stage = terraform.workspace == "default" ? "prod" : terraform.workspace
}


module "vpc" {
  source    = "../shared/modules/vpc"
  namespace = var.namespace
  stage     = var.stage

  cidr_block = var.cidr_block
  aws_region = var.aws_region
  az_count   = var.az_count

  ssh_allow_cidrs = var.ssh_allow_cidrs

  http_allow_cidrs = var.http_allow_cidrs
  http_ports       = var.http_ports

  private_subnet_tags = {
    "karpenter.sh/discovery" = "${var.namespace}-${local.stage}"
  }

  public_subnet_tags = {
    # "karpenter.sh/discovery" = "${var.namespace}-${local.stage}"
  }

  enable_private_net      = var.enable_private_net
  map_public_ip_on_launch = var.map_public_ip_on_launch
}



module "eks" {
  source      = "../shared/modules/eks"
  eks_version = "1.30"

  namespace  = var.namespace
  stage      = local.stage
  aws_region = var.aws_region

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  managed_node_groups = {
    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      labels = {
        role = "spot"
      }

      # https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"

    }

    ondemand = {
      desired_size = 1
      min_size     = 1
      max_size     = 3

      labels = {
        role = "on-demand"
      }
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]
      capacity_type  = "ON_DEMAND"
    }
  }

  cluster_security_group_id = module.vpc.allow_local_all

  access_entries = var.access_entries

}

module "eks-addons" {
  source = "../shared/modules/eks-addons"
}
