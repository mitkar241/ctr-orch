#!/bin/bash

set -e
set -x

# Set namespace and Vault pod name
NAMESPACE="vault"
VAULT_POD=$(kubectl -n $NAMESPACE get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

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

# Put a secret in Vault at the 'ingress' path
echo "Putting secret 'foo=bar' at 'ingress/mysecret'..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault kv put ingress/mysecret foo=bar

# List all secrets engines
echo "Listing all secrets engines..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault secrets list

# Write AppRole configuration to role 'ingress' with 'read-policy'
echo "Writing AppRole configuration to role 'ingress' with 'read-policy'..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write auth/approle/role/ingress token_policies="read-policy"

# Read AppRole configuration for role 'ingress'
echo "Reading AppRole configuration for role 'ingress'..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault read auth/approle/role/ingress

# Get the role ID for the 'ingress' role
echo "Getting role ID for AppRole 'ingress'..."
ROLE_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault read -field=role_id auth/approle/role/ingress/role-id)
ROLE_ID=$(clean_vault_output "$ROLE_ID")
echo "Role ID: $ROLE_ID"

# Create a new secret ID for the 'ingress' AppRole
echo "Creating a new secret ID for AppRole 'ingress'..."
SECRET_ID=$(kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write -field=secret_id -force auth/approle/role/ingress/secret-id)
SECRET_ID=$(clean_vault_output "$SECRET_ID")
echo "Secret ID: $SECRET_ID"

## od -c: The od command (octal dump) will display all characters, including hidden ones. This will help us see if there are any unexpected characters or escape sequences.
#test="abcd"
#echo "$test" | od -c
#echo "$ROLE_ID" | od -c
#echo "$SECRET_ID" | od -c

# Login to Vault using the AppRole credentials
echo "Logging in to Vault with AppRole..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault write auth/approle/login role_id="$ROLE_ID" secret_id="$SECRET_ID"

# List the secrets at the 'ingress' path
echo "Listing secrets at 'ingress/'..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault kv list ingress/

# Get the secret stored at 'ingress/mysecret'
echo "Getting secret stored at 'ingress/mysecret'..."
kubectl -n $NAMESPACE exec -it $VAULT_POD -- vault kv get ingress/mysecret
