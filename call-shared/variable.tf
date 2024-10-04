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

#################
###    helm   ###
#################



#### Mysql
variable "mysql_root_user" {
  description = "my sql root user"
  type        = string

}
variable "mysql_secrect_name" {
  description = "Secrect name for mysql configuration"
  type        = string
}

variable "mysql_root_password" {
  description = "Base64 encoded MySQL root password"
  type        = string
}

variable "mysql_replication_password" {
  description = "Base64 encoded MySQL replication password"
  type        = string
}

variable "mysql_replication_user" {
  description = "Base64 encoded MySQL replication user"
  type        = string
}

variable "mysql_password" {
  description = "Base64 encoded MySQL user password"
  type        = string
}


### Worpress


variable "wordpress_configs" {
  description = "List of WordPress configurations"
  type        = list(object({
    database_name     = string
    database_user     = string
    database_password = string
    wp_admin_user     = string
    wp_admin_password = string
    wp_admin_email    = string
    wp_first_name     = string
    wp_last_name      = string
    multisite_enable  = string
    service_type      = string
  }))
}


# variable "database_name" {
#   description = "The database name"
#   type        = string
# }

# variable "database_user" {
#   description = "The admin username of the database"
#   type        = string
# }

# variable "database_password" {
#   description = "The admin password of the database"
#   type        = string
# }

# variable "wp_admin_user" {
#   description = "WordPress admin username"
#   type        = string
# }

# variable "wp_admin_password" {
#   description = "WordPress admin password"
#   type        = string
# }

# variable "wp_admin_email" {
#   description = "WordPress admin email"
#   type        = string
# }

# variable "wp_first_name" {
#   description = "WordPress admin first name"
#   type        = string
# }

# variable "wp_last_name" {
#   description = "WordPress admin last name"
#   type        = string
# }

# variable "multisite_enable" {
#   description = "Enable WordPress multi-site"
#   type        = string
# }

# variable "service_type" {
#   default = "service type for wordpress instance"
#   type    = string

# }

