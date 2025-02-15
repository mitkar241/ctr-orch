#!/bin/bash

set -e
set -x

echo "Creating namespace 'ingress-nginx'..."
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

echo "Adding Helm repository for Nginx Ingress..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Installing Nginx Ingress Controller..."
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --values ingress/values.yaml

echo "Waiting for Nginx Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=available deployment/nginx-ingress-ingress-nginx-controller \
  --timeout=300s

echo "Nginx Ingress Controller is installed and ready!"
