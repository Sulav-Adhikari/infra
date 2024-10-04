###################
#  mysql-secrect  #
###################
resource "kubernetes_secret" "sql_secrect" {
  metadata {
    name      = var.mysql_secrect_name
    namespace = "kube-system"
  }

  data = {
    mysql-root-password        = var.mysql_root_password
    mysql-replication-user     = var.mysql_replication_user
    mysql-replication-password = var.mysql_replication_password
    mysql-password             = var.mysql_password

  }
  type = "Opaque"
}

###################
#  Storage Class  #
###################

resource "kubernetes_storage_class" "ebs_gp2" {
  metadata {
    name = "my-ebs-sc" # The name of the StorageClass
  }

  storage_provisioner    = "ebs.csi.aws.com"      # Provisioner for EBS CSI driver
  reclaim_policy         = "Delete"               # Reclaim policy when the volume is released
  volume_binding_mode    = "WaitForFirstConsumer" # Ensures volume is provisioned where the pod runs
  allow_volume_expansion = true                   # Allows resizing the volume

  parameters = {
    type = "gp2" # Volume type
  }
  lifecycle {
    ignore_changes = all
  }
}


# helm 

resource "helm_release" "traefik" {

  name             = "traefik"
  chart            = "traefik"
  namespace        = "kube-system"
  repository       = "https://traefik.github.io/charts"
  version          = "32.0.0"
  create_namespace = true

  values = [
    file("../shared/modules/eks-addons/helm-values/config/traefikvalues.yaml")

  ]
  
}

# Apply the Helm release for MySQL
resource "helm_release" "mysql" {
  name             = "mysql"
  chart            = "mysql"
  namespace        = "kube-system"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "11.1.16"
  create_namespace = true

  values = [
    file("../shared/modules/eks-addons/helm-values/config/mysqlvalues.yaml") # Path to your custom values file #issue mysqlvalues.yaml must exist prior to apply
  ]

  depends_on = [kubernetes_secret.sql_secrect]
}

# Apply the Helm release for phpmyadmin
resource "helm_release" "phpmyadmin" {
  name             = "phpmyadmin"
  chart            = "phpmyadmin"
  namespace        = "kube-system"
  repository       = "https://charts.bitnami.com/bitnami" # Bitnami's Helm repo URL
  version          = "17.0.6"                             # Specify version from Bitnami
  create_namespace = true                                 # Creates namespace if it doesn't exist
  values = [
    file("../shared/modules/eks-addons/helm-values/config/phpmyadminvalues.yaml") # Path to your custom values file #issue mysqlvalues.yaml must exist prior to apply
  ]

  depends_on = [helm_release.mysql]
}


#################
#kubernetes role#
#################

resource "kubernetes_role" "mysql_exec_role" {
  metadata {
    namespace = "kube-system"
    name      = "mysql-exec-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec", "pods/log","pods"]
    verbs      = ["create", "get", "list", "watch"]
  }
}

#########################
#kubernetes role binbing#
#########################

resource "kubernetes_role_binding" "mysql_exec_role_binding" {
  metadata {
    namespace = "kube-system"
    name      = "mysql-exec-rolebinding"
  }

  role_ref {
    kind     = "Role"
    name     = kubernetes_role.mysql_exec_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default" # Specify the service account name
    namespace = "kube-system" 
  }
}

# Generate the values file
resource "local_file" "wordpress_values" {
  filename = "${path.module}/config/wpvalues-${var.database_name}.yaml"
  content = templatefile("${path.module}/config/wordpress.tftpl", {
    database_name      = var.database_name
    database_user      = var.database_user
    database_password  = var.database_password
    wp_admin_user      = var.wp_admin_user
    wp_admin_password  = var.wp_admin_password
    wp_admin_email     = var.wp_admin_email
    wp_first_name      = var.wp_first_name
    wp_last_name       = var.wp_last_name
    multisite_enable   = var.multisite_enable
    mysql_root_user    = var.mysql_root_user
    mysql_root_password = var.mysql_root_password
    service_type       = var.service_type
    storage_class_name = kubernetes_storage_class.ebs_gp2.metadata[0].name
  })
}

#configmap for script
resource "kubernetes_config_map" "wordpress_script" {
  metadata {
    name      = "wordpress-script"
    namespace = "kube-system"
  }
  data = {
    "wordpress.sh" = file("${path.module}/config/wordpress.sh")
  }
  depends_on = [ helm_release.mysql ]
}

#job to execute the script
resource "kubernetes_job" "wordpress_deployment" {
  metadata {
    name = "wordpress-deployment-${formatdate("YYYYMMDDhhmmss", timestamp())}"
    namespace = "kube-system"

  }

  spec {
    template {
      metadata {
        name = "wordpress-deployment"
      }
      spec {
        container {
          name = "wordpress-deployment"
          image = "bitnami/kubectl:latest"
          command = ["/bin/sh", "/scripts/wordpress.sh"]
          args = [
            var.database_name,
            var.database_user,
            var.database_password,
            var.mysql_root_user,
            var.mysql_root_password,  
          ]
          volume_mount {
            name       = "script"
            mount_path = "/scripts"
          }
        }
        volume {
          name = "script"
          config_map {
            name = kubernetes_config_map.wordpress_script.metadata[0].name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  depends_on = [ kubernetes_config_map.wordpress_script ]
}


resource "helm_release" "wordpress"{
  name             = "wordpress-${var.database_name}"
  chart            = "wordpress"
  namespace        = "kube-system"
  repository       = "https://charts.bitnami.com/bitnami" # Bitnami's Helm repo URL
  version          = "23.1.17"                             # Specify version from Bitnami
  create_namespace = true 

  values = [
    local_file.wordpress_values.content
  ]

  depends_on = [ local_file.wordpress_values, kubernetes_job.wordpress_deployment ]

}

