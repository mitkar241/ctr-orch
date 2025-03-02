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

# Retrieve AppRole credentials
APPROLE_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault read -field=role_id auth/approle/role/external-secrets/role-id)
APPROLE_ID=$(clean_vault_output "$APPROLE_ID")
SECRET_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write -field=secret_id -force auth/approle/role/external-secrets/secret-id)
SECRET_ID=$(clean_vault_output "$SECRET_ID")

# Step 4: Populate values.yaml for Helm
echo "Populating values.yaml with roleId and secretId..."
cat <<EOF > eso/values.yaml
isClusterSecretStore: true
roleID: $APPROLE_ID
secretID: $SECRET_ID
EOF

echo "Waiting for all External Secrets deployments to be ready..."
kubectl -n external-secrets wait \
  --for=condition=available deployment/external-secrets \
  --for=condition=available deployment/external-secrets-cert-controller \
  --for=condition=available deployment/external-secrets-webhook \
  --timeout=300s

# Step 5: Generate Helm templates
#echo "Generating Helm templates..."
#helm template eso eso/

# Step 6: Install the External Secrets Helm release
echo "Installing the External Secrets Helm chart..."
helm install eso eso/
