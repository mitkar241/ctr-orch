#!/bin/bash

set -e
set -x

echo "Uninstalling Flannel..."

# Uninstall the Helm release
helm uninstall flannel -n kube-flannel || true

# Delete the namespace if it exists
kubectl delete namespace kube-flannel --ignore-not-found=true

echo "Flannel has been removed successfully!"
