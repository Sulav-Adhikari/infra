provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}


provider "helm" {
  kubernetes {

    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }

  }
}


provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.namespace
      Description = "Managed by Terrafrom"
    }
  }
}

