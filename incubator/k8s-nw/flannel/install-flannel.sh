#!/bin/bash

set -e
set -x

echo "Creating namespace 'kube-flannel'..."
kubectl create namespace kube-flannel --dry-run=client -o yaml | kubectl apply -f -

#kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

echo "Adding Helm repository for Flannel..."
helm repo add flannel https://flannel-io.github.io/flannel/
helm repo update

echo "Installing Flannel..."
helm -n kube-flannel install flannel flannel/flannel --values flannel/values.yaml

echo "Waiting for Flannel to be ready..."
kubectl -n kube-flannel rollout status daemonset kube-flannel-ds --timeout 300s

echo "Flannel is installed and ready!"
