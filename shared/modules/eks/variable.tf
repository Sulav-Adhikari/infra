variable "namespace" {
  description = "Namespace (e.g. `oneaccord`)"
  type        = string
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
}
variable "aws_region" {
  type = string
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  type = string
}

variable "cluster_security_group_id" {
  type = string
}

variable "enable_cluster_creator_admin_permissions" {
  default = true
  type    = bool
}



variable "subnet_ids" {
  type = list(string)
}

variable "managed_node_groups" {
  type = map(any)
  default = {
    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 3

      labels = {
        role = "spot"
      }

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"
    }
  }
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

