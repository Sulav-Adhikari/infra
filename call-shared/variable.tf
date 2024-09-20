variable "aws_region" {
  type        = string
  description = "AWS region to create resource"
  default     = "us-east-1"
}

###VPC####
variable "cidr_block" {
  type = string
}
variable "namespace" {
  description = "Namespace"
  type        = string
}

variable "stage" {
  description = "Stage"
  type        = string
}

variable "az_count" {
  type    = string
  default = "2"
}
variable "map_public_ip_on_launch" {
  default     = true
  type        = bool
  description = "map public ip on launch"
}

variable "enable_private_net" {
  default = true
  type    = bool
}

#-sg-#
variable "http_ports" {
  type        = list(number)
  default     = []
  description = "web ports"
}

variable "ssh_allow_cidrs" {
  type    = list(string)
  default = []
  # default     = ["0.0.0.0/0"]
  description = "web allow cidrs"
}
variable "http_allow_cidrs" {
  type        = list(string)
  description = "web allow cidrs"
  default     = []
}

// ==EKS ===

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}