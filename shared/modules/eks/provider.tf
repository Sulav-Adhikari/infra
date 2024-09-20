terraform {
  required_version = ">=1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.28.0"
    }

    # kubectl = {
    #   source  = "alekc/kubectl"
    #   version = "~> 2.0"
    # }
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
