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

variable "service_type" {
  default = "service type for wordpress instance"
  type    = string

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

