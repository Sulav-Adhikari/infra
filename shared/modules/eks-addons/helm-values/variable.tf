variable "namespace" {
  description = "Namespace"
  type        = string
}

variable "aws_region" {
  type = string
}



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


###eks

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

