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
    "karpenter.sh/discovery" = "${var.namespace}-${local.stage}"
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
      instance_types = ["t2.medium"]
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
      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  cluster_security_group_id = module.vpc.allow_local_all

  access_entries = var.access_entries
}

module "eks-addons" {
  source = "../shared/modules/eks-addons/helm-values"
  #mysql secrect
  mysql_secrect_name         = var.mysql_secrect_name
  mysql_root_user            = var.mysql_root_user
  mysql_root_password        = var.mysql_root_password
  mysql_replication_password = var.mysql_replication_password
  mysql_replication_user     = var.mysql_replication_user
  mysql_password             = var.mysql_password

  #Wordpress
  database_name     = var.database_name
  database_user     = var.database_user
  database_password = var.database_password
  wp_admin_user     = var.wp_admin_user
  wp_admin_password = var.wp_admin_password
  wp_admin_email    = var.wp_admin_email
  wp_first_name     = var.wp_first_name
  wp_last_name      = var.wp_last_name
  multisite_enable  = var.multisite_enable
  
  cluster_name               = module.eks.eks_cluster
  cluster_endpoint           = module.eks.cluster_endpoint
  certificate_authority_data = module.eks.certificate_authority_data
  
  service_type = var.service_type

}
