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

# Apply the Helm release for MySQL
resource "helm_release" "mysql" {
  name             = "mysql"
  chart            = "mysql"
  namespace        = "kube-system"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "11.1.16"
  create_namespace = true

  set {
    name  = "architecture"
    value = "replication"
  }

  set {
    name  = "auth.existingSecret"
    value = var.mysql_secrect_name
  }

  set {
    name  = "primary.persistence.enabled"
    value = var.persistence_enable_primary 
  }

  set {
    name  = "primary.persistence.accessModes[0]"
    value = var.access_modes_primary
  }

  set {
    name  = "primary.persistence.size"
    value = var.size_primary
  }

  set {
    name  = "secondary.replicaCount"
    value = var.replica_count 
  }

  set {
    name  = "secondary.persistence.accessModes[0]"
    value = var.access_modes_secondary 
  }

  set {
    name  = "secondary.persistence.size"
    value = var.size_secondary
  }
  # values = [
  #   file("../shared/modules/eks-addons/helm-values/config/mysqlvalues.yaml")  # Path to your custom values file #issue mysqlvalues.yaml must exist prior to apply
  # ]

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

  set {
    name  = "service.type"
    value = var.service_type
  }

  set {
    name  = "service.ports.http"
    value = "80"
  }

  set {
    name  = "service.ports.https"
    value = "443"
  }

  set {
    name  = "db.host"
    value = var.host
  }

  set {
    name  = "db.port"
    value = var.db_port
  }

  set {
    name  = "db.enableSsl"
    value = false
  }

  set {
    name  = "ingress.enabled"
    value = var.ingress_enable
  }

  set {
    name  = "ingress.hostname"
    value = var.hostname
  }

  set {
    name  = "ingress.tls"
    value = var.tls_enable
  }

  values = [
    file("../shared/modules/eks-addons/helm-values/config/phpmyadminvalues.yaml") # Path to your custom values file #issue mysqlvalues.yaml must exist prior to apply
  ]


  depends_on = [helm_release.mysql]

}
