#!/bin/bash

# Check if required number of arguments are provided
if [ "$#" -ne 11 ]; then
  echo "Usage: $0 <database_name> <database_user> <database_password> <wp_admin_user> <wp_admin_password> <wp_admin_email> <wp_first_name> <wp_last_name> <multisite_enable>"
  exit 1
fi

# Assign arguments to variables
DATABASE_NAME=$1
DATABASE_USER=$2
DATABASE_PASSWORD=$3
WP_ADMIN_USER=$4
WP_ADMIN_PASSWORD=$5
WP_ADMIN_EMAIL=$6
WP_FIRST_NAME=$7
WP_LAST_NAME=$8
MULTISITE_ENABLE=$9
MYSQL_USER=${10}
MYSQL_PASSWORD=${11}



# Define your label or part of the pod name to filter
POD_LABEL_PART="primary"

# Get the name of the MySQL primary pod using grep and awk
POD_NAME=$(kubectl get pods | grep $POD_LABEL_PART | awk '{print $1}')

# Check if we got a pod name
if [ -z "$POD_NAME" ]; then
  echo "No pod found with label part $POD_LABEL_PART"
  exit 1
fi

# Define MySQL credentials (root user)
MYSQL_USER="$MYSQL_USER"
MYSQL_PASSWORD="$MYSQL_PASSWORD"

echo "Database Name: $DATABASE_NAME"
echo "Database User: $DATABASE_USER"
echo "Database Password: $DATABASE_PASSWORD"
echo "WP Admin User: $WP_ADMIN_USER"
echo "WP Admin Password: $WP_ADMIN_PASSWORD"
echo "WP Admin Email: $WP_ADMIN_EMAIL"
echo "WP First Name: $WP_FIRST_NAME"
echo "WP Last Name: $WP_LAST_NAME"
echo "Multisite Enable: $MULTISITE_ENABLE"
echo "MySQL User: $MYSQL_USER"
echo "MySQL Password: $MYSQL_PASSWORD"

# SQL commands to create a database, user, and grant privileges dynamically
MYSQL_COMMANDS=$(cat <<EOF
CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;

CREATE USER IF NOT EXISTS '$DATABASE_USER'@'%' IDENTIFIED BY '$DATABASE_PASSWORD';

GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$DATABASE_USER'@'%';

FLUSH PRIVILEGES;
EOF
)

# Execute commands inside the MySQL pod
echo "Creating database '$DATABASE_NAME' and user '$DATABASE_USER' inside pod $POD_NAME..."
kubectl exec -it "$POD_NAME" -- mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "$MYSQL_COMMANDS"
echo "kubectl exec -it $POD_NAME -- mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e \"$MYSQL_COMMANDS\""


# Check if the command executed successfully
if [ $? -eq 0 ]; then
  echo "Database '$DATABASE_NAME' and user '$DATABASE_USER' created successfully with privileges."
else
  echo "Failed to create database or user, or grant privileges."
  exit 1
fi

# Generate dynamic values.yaml for Helm
VALUES_FILE="wpvalues-$DATABASE_NAME.yaml"

cat <<EOF > "$VALUES_FILE"
externalDatabase:
  host: mysql-primary  # Use your MySQL service name
  port: 3306
  user: $DATABASE_USER              # The MySQL user with the necessary privileges
  password: $DATABASE_PASSWORD      # The MySQL password for the user
  database: $DATABASE_NAME       # The specific database created for WordPress
  enableSsl: false               # Disable SSL verification

mariadb:
  enabled: false                       # Disable the internal MariaDB deployment

wordpressUsername: $WP_ADMIN_USER      # WordPress admin username
wordpressPassword: $WP_ADMIN_PASSWORD  # WordPress admin password
wordpressEmail: $WP_ADMIN_EMAIL        # WordPress admin email
wordpressFirstName: $WP_FIRST_NAME     # WordPress admin first name
wordpressLastName: $WP_LAST_NAME       # WordPress admin last name

service:
  type: ClusterIP
  ports:
    http: 80
    https: 443

ingress:
  enabled: true  # Enable Ingress if using it
  hostname: $DATABASE_NAME.wp.np
  annotations:
    kubernetes.io/ingress.class: traefik
  tls: false  # Enable TLS if needed (requires a certificate setup)
EOF

# Add extraHosts and multi-site configuration if enabled
if [ "$MULTISITE_ENABLE" == "yes" ]; then
  cat <<EOF >> "$VALUES_FILE"
extraHosts:
  - name: test.$DATABASE_NAME.wp.np
    path: /

multisite:
  enable: true
  host: "$DATABASE_NAME.wp.np"
  networkType: subdomain
  enableNipIoRedirect: false
EOF
fi

# Use Helm to deploy the WordPress instance using the generated values.yaml
echo "Deploying WordPress instance for '$DATABASE_NAME'..."
kubeconfig="$KUBECONFIG_PATH" helm install wordpress-$DATABASE_NAME bitnami/wordpress --version 23.1.12 -f "$VALUES_FILE"
if [ $? -eq 0 ]; then
  echo "WordPress instance for '$DATABASE_NAME' deployed successfully."
else
  echo "Failed to deploy WordPress instance for '$DATABASE_NAME'."
  exit 1
fi
