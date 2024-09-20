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

variable "aws_region" {
  type = string
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

#-----sg------

variable "http_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "web ports"
}

variable "http_allow_cidrs" {
  type        = list(string)
  description = "web allow cidrs"
}

variable "ssh_allow_cidrs" {
  description = "ssh allow cidrs"
  type        = list(string)
}

variable "private_subnet_tags" {
  description = "Private subnet tags."
  type        = map(any)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Private subnet tags."
  type        = map(any)
  default     = {}
}
