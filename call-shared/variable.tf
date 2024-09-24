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


###helm###
#### Mysql

variable "mysql_secrect_name" {
  description = "Secrect name for mysql configuration"
  type        = string
}

variable "persistence_enable_primary" {
  description = "enable presistence sql instance (primary and secondary)"
  type        = bool
}


variable "access_modes_primary" {
  description = "access mode for PV eg ReadWriteOnce"
  type        = string

}

variable "size_primary" {
  description = "Size of PV eg 10gi"
  type        = string

}

variable "replica_count" {
  description = "Replica Count for secondary mysql pod"
  type        = number
}

variable "persistence_enable_secondary" {
  description = "enable presistence sql instance (primary and secondary)"
  type        = bool
}


variable "access_modes_secondary" {
  description = "access mode for PV eg ReadWriteOnce"
  type        = string

}

variable "size_secondary" {
  description = "Size of PV eg 10gi"
  type        = string

}

variable "mysql_root_user" {
  description = "mysql root user"
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

#phpmyadmin

variable "service_type" {
  description = "service type"
  type        = string
}


variable "host" {
  description = "database host i.e svc for primary"
  type        = string
  default     = "mysql-primary"
}

variable "db_port" {
  type    = string
  default = "3306"

}
variable "ingress_enable" {
  description = "enable or disable ingress"
  type        = bool
  default     = true
}

variable "hostname" {
  description = "domain for phpmyadmin"
  type        = string
  default     = "phpmyadmin.local"

}

variable "tls_enable" {
  description = "enable or disable"
  type        = bool
  default     = false
}


### Worpress

variable "remote_host" {
  description = "The IP or hostname of the remote server"
  type        = string
}

variable "remote_user" {
  description = "The SSH user for the remote server"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for accessing the remote server"
  type        = string
}

variable "database_name" {
  description = "The database name"
  type        = string
}

variable "database_user" {
  description = "The admin username of the database"
  type        = string
}

variable "database_password" {
  description = "The admin password of the database"
  type        = string
}

variable "wp_admin_user" {
  description = "WordPress admin username"
  type        = string
}

variable "wp_admin_password" {
  description = "WordPress admin password"
  type        = string
}

variable "wp_admin_email" {
  description = "WordPress admin email"
  type        = string
}

variable "wp_first_name" {
  description = "WordPress admin first name"
  type        = string
}

variable "wp_last_name" {
  description = "WordPress admin last name"
  type        = string
}

variable "multisite_enable" {
  description = "Enable WordPress multi-site"
  type        = string
}

