#!/bin/bash

set -e
set -x

# Set namespace and Helm chart name
NAMESPACE="vault"
HELM_CHART="hashicorp/vault"

# Install Vault via Helm
echo "Installing Vault using Helm..."
helm repo add hashicorp https://helm.releases.hashicorp.com
#helm repo update
helm -n $NAMESPACE install vault $HELM_CHART --create-namespace

# Get the Vault pod
VAULT_POD=$(kubectl -n $NAMESPACE get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')
echo "Vault pod: $VAULT_POD"

# Wait for all Vault StatefulSet pods to have status 'Running' (not necessarily 'Ready')
echo "Waiting for Vault StatefulSet pods to have status 'Running'..."

#kubectl -n $NAMESPACE wait --for=condition=ready --timeout=600s pod -l app.kubernetes.io/name=vault

# Loop until the pod status becomes Running
while true; do
  POD_STATUS=$(kubectl -n $NAMESPACE get pod $VAULT_POD -o jsonpath='{.status.phase}')
  if [[ "$POD_STATUS" == "Running" ]]; then
    echo "Vault pod is in 'Running' state."
    break
  else
    echo "Vault pod is not yet 'Running'. Current status: $POD_STATUS. Retrying..."
    sleep 10  # wait 10 seconds before checking again
  fi
done

# Initialize Vault and capture the JSON output
echo "Initializing Vault..."
INIT_OUTPUT=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator init -format=json)

# Cache unseal keys and root token from the JSON output
UNSEAL_KEY_1=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[0]')
UNSEAL_KEY_2=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[1]')
UNSEAL_KEY_3=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[2]')
ROOT_TOKEN=$(echo $INIT_OUTPUT | jq -r '.root_token')

echo "Vault initialized. Unseal keys and root token cached."

# Unseal Vault using the unseal keys
echo "Unsealing Vault..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator unseal $UNSEAL_KEY_1
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator unseal $UNSEAL_KEY_2
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault operator unseal $UNSEAL_KEY_3

# Login to Vault using the root token
echo "Logging into Vault with root token..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault login $ROOT_TOKEN

# Enable KV secrets engine at 'ingress' path
echo "Enabling KV secrets engine at 'ingress' path..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault secrets enable -version=2 -path=ingress kv

# Enable AppRole authentication
echo "Enabling AppRole authentication..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault auth enable approle

# Write a read-only policy for the 'ingress' path
echo "Creating read-only policy for 'ingress' path..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault policy write read-policy -<<EOF
# Read-only permission on secrets stored at 'ingress/data'
path "ingress/*" {
  capabilities = [ "read", "list" ]
}
EOF

echo "Vault setup complete!"
