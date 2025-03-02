#!/bin/sh

set -e
set -x

echo "Running test inside the cluster..."

# Create a temporary test pod
kubectl run my-app-client --image=busybox --restart=Never -- sleep 20 &

# Wait for the pod to be ready
sleep 3
kubectl wait --for=condition=ready pod/my-app-client --timeout=10s || true

# Execute test request
kubectl exec my-app-client -- wget -qO- --header="Host: my-app.local" http://nginx-ingress-ingress-nginx-controller.ingress-nginx.svc.cluster.local || true

# Execute nslookup
kubectl exec my-app-client -- nslookup my-app.default.svc.cluster.local kube-dns.kube-system.svc.cluster.local

# Execute nslookup
kubectl exec my-app-client -- nslookup my-app.mitkar.io kube-dns.kube-system.svc.cluster.local

# verify that the Ingress is handling traffic correctly using curl
#kubectl exec -it my-app-client -- curl -k -H "Host: my-app.mitkar.io" https://my-app.mitkar.io

#kubectl exec -it my-app-client -- wget --header="Host: my-app.mitkar.io" -qO- http://10.0.2.15

#kubectl exec -it my-app-client -- wget --no-check-certificate --header="Host: my-app.mitkar.io" -qO- https://10.0.2.15

kubectl exec -it my-app-client -- wget --header="Host: my-app.mitkar.io" -qO- https://10.0.2.15

#kubectl exec -it my-app-client -- openssl s_client -connect 10.0.2.15:443 -servername my-app.mitkar.io </dev/null

kubectl exec -it my-app-client -- wget --no-check-certificate -qO- https://my-app.mitkar.io

kubectl exec -it my-app-client -- wget -qO- https://my-app.mitkar.io
