#!/bin/bash

set -e
set -x

echo "Uninstalling Nginx Ingress Controller..."

# Uninstall the Helm release
helm uninstall nginx-ingress -n ingress-nginx || true

# Delete the namespace if it exists
kubectl delete namespace ingress-nginx --ignore-not-found=true

echo "Nginx Ingress Controller has been removed successfully!"
