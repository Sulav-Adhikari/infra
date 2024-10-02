#!/bin/bash
# Assign arguments to variables
DATABASE_NAME=$1
DATABASE_USER=$2
DATABASE_PASSWORD=$3
MYSQL_USER=$4
MYSQL_PASSWORD=$5

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


# Check if the command executed successfully
if [ $? -eq 0 ]; then
  echo "Database '$DATABASE_NAME' and user '$DATABASE_USER' created successfully with privileges."
else
  echo "Failed to create database or user, or grant privileges."
  exit 1
fi
