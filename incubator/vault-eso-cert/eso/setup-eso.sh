#!/bin/bash

set -e
set -x

# Set namespace and Vault pod name
NAMESPACE="vault"
VAULT_POD=$(kubectl -n $NAMESPACE get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

# Function to clean Vault output
# Function to clean the raw output from Vault and remove hidden characters, escape sequences, and formatting
clean_vault_output() {
  local raw_output="$1"
  
  # Remove ANSI escape sequences (for formatting)
  cleaned_output=$(echo "$raw_output" | sed 's/\x1b\[[0-9;]*m//g')
  
  # Remove carriage return and newline characters
  cleaned_output=$(echo "$cleaned_output" | tr -d '\r\n')
  
  # Remove any surrounding single quotes (if any)
  cleaned_output=$(echo "$cleaned_output" | sed "s/'//g")
  
  echo "$cleaned_output"
}

# Step 1: Install External Secrets using Helm
echo "Adding External Secrets Helm repo..."
#helm repo add external-secrets https://charts.external-secrets.io
#helm repo update

echo "Installing External Secrets..."
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true

# Step 2: Get the Role ID for the 'ingress' AppRole
echo "Getting role ID for AppRole 'ingress'..."
ROLE_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault read -field=role_id auth/approle/role/ingress/role-id)
ROLE_ID=$(clean_vault_output "$ROLE_ID")
echo "Role ID: $ROLE_ID"

# Step 3: Create a new Secret ID for the 'ingress' AppRole
echo "Creating a new secret ID for AppRole 'ingress'..."
SECRET_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write -field=secret_id -force auth/approle/role/ingress/secret-id)
SECRET_ID=$(clean_vault_output "$SECRET_ID")
echo "Secret ID: $SECRET_ID"

# Step 4: Populate values.yaml for Helm
echo "Populating values.yaml with roleId and secretId..."
cat <<EOF > eso/values.yaml
isClusterSecretStore: true
roleID: $ROLE_ID
secretId: $SECRET_ID
EOF

# Step 5: Generate Helm templates
echo "Generating Helm templates..."
helm template eso eso/ -f eso/values.yaml

# Step 6: Install the External Secrets Helm release
echo "Installing the External Secrets Helm chart..."
helm install eso eso/ -f eso/values.yaml

#$ kubectl get secret example-secret -o jsonpath='{.data.foobar}' | base64 --decode
#bar
