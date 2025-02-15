#!/bin/sh

set -e
set -x

echo "Running test inside the cluster..."

# Create a temporary test pod
kubectl run my-app-client --image=busybox --restart=Never -- sleep 10 &

# Wait for the pod to be ready
sleep 3
kubectl wait --for=condition=ready pod/my-app-client --timeout=10s || true

# Execute test request
kubectl exec my-app-client -- wget -qO- --header="Host: my-app.local" http://nginx-ingress-ingress-nginx-controller.ingress-nginx.svc.cluster.local || true
