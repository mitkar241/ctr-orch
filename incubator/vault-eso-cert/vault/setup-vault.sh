#!/bin/bash

set -e
set -x

# Set namespace and Helm chart name
NAMESPACE="vault"
HELM_CHART="hashicorp/vault"

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

echo "Installing External Secrets..."
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true

# Install Vault via Helm
echo "Installing Vault using Helm..."
helm repo add hashicorp https://helm.releases.hashicorp.com
helm -n $NAMESPACE install vault $HELM_CHART --create-namespace

# Get the Vault pod
VAULT_POD=$(kubectl -n $NAMESPACE get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')
echo "Vault pod: $VAULT_POD"

# Wait for Vault pod to be in 'Running' state
echo "Waiting for Vault pod to be in 'Running' state..."
while true; do
  POD_STATUS=$(kubectl -n $NAMESPACE get pod $VAULT_POD -o jsonpath='{.status.phase}')
  if [[ "$POD_STATUS" == "Running" ]]; then
    echo "Vault pod is in 'Running' state."
    break
  else
    echo "Vault pod is not yet 'Running'. Current status: $POD_STATUS. Retrying..."
    sleep 10
  fi
done

# Initialize Vault if not already initialized
if ! kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault status | grep -q "Initialized.*true"; then
  echo "Initializing Vault..."
  INIT_OUTPUT=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator init -format=json)
  
  # Cache unseal keys and root token
  UNSEAL_KEY_1=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[0]')
  UNSEAL_KEY_2=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[1]')
  UNSEAL_KEY_3=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[2]')
  ROOT_TOKEN=$(echo $INIT_OUTPUT | jq -r '.root_token')

  echo "Vault initialized. Unseal keys and root token cached."

  # Unseal Vault
  echo "Unsealing Vault..."
  kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator unseal $UNSEAL_KEY_1
  kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator unseal $UNSEAL_KEY_2
  kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator unseal $UNSEAL_KEY_3
else
  echo "Vault is already initialized."
fi

# Login to Vault
echo "Logging into Vault with root token..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault login $ROOT_TOKEN

# Enable KV secrets engine at 'ingress' path
echo "Enabling KV secrets engine at 'ingress' path..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault secrets enable -version=2 -path=ingress kv

#######################################################


# Enable PKI and generate root CA
echo "Enabling PKI secrets engine..."
kubectl -n $NAMESPACE exec -it "$VAULT_POD" -- vault secrets enable pki || echo "PKI already enabled."

echo "Configuring PKI Root CA..."
kubectl -n $NAMESPACE exec -it "$VAULT_POD" -- vault write pki/root/generate/internal \
    common_name="mitkar.io" ttl="87600h"

echo "Creating PKI role for certificate issuance..."
kubectl -n $NAMESPACE exec -it "$VAULT_POD" -- vault write pki/roles/mitkar-io \
    allowed_domains="mitkar.io" \
    allow_subdomains=true \
    max_ttl="72h"

# Issue TLS Certificate
echo "Generating TLS certificate for my-app.mitkar.io..."
kubectl -n $NAMESPACE exec -it "$VAULT_POD" -- vault write -format=json pki/issue/mitkar-io \
    common_name="my-app.mitkar.io" ttl="24h" > cert_output.json

# Extract Certificate Data
CRT=$(jq -r '.data.certificate' < cert_output.json)
KEY=$(jq -r '.data.private_key' < cert_output.json)
CA=$(jq -r '.data.issuing_ca' < cert_output.json)

# Store Certs in Vault KV Store
echo "Storing certificates in Vault KV store..."
kubectl -n $NAMESPACE exec -it "$VAULT_POD" -- vault kv put ingress/my-app.mitkar.io \
    ca.crt="$CA" tls.crt="$CRT" tls.key="$KEY"


########################################################

# Enable AppRole authentication
echo "Enabling AppRole authentication..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault auth enable approle

# Create a read policy for 'ingress' path
echo "Creating read-only policy for 'ingress' path..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault policy write ingress-read-policy - <<EOF
path "ingress/data/my-app.mitkar.io" {
  capabilities = ["read", "list"]
}
EOF

# Create AppRole and attach policy
echo "Creating AppRole for External Secrets..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write auth/approle/role/external-secrets \
  token_policies="ingress-read-policy" \
  token_ttl=1h \
  token_max_ttl=4h

# Retrieve AppRole credentials
APPROLE_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault read -field=role_id auth/approle/role/external-secrets/role-id)
APPROLE_ID=$(clean_vault_output "$APPROLE_ID")
SECRET_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write -field=secret_id -force auth/approle/role/external-secrets/secret-id)
SECRET_ID=$(clean_vault_output "$SECRET_ID")

# Create Kubernetes Secret with AppRole credentials
#echo "Creating Kubernetes Secret vault-secret..."
#kubectl create secret generic vault-secret \
#  --from-literal=VAULT_ADDR='http://vault.vault.svc:8200' \
#  --from-literal=VAULT_ROLE_ID="$APPROLE_ID" \
#  --from-literal=VAULT_SECRET_ID="$SECRET_ID" \
#  -n default

echo "Vault setup complete!"
