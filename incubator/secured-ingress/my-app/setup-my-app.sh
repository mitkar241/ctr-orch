#!/bin/sh

set -e
set -x

grep -Pq "^\s*10\.0\.2\.15\s+my-app\.mitkar\.io\b" /etc/hosts || echo "10.0.2.15 my-app.mitkar.io" | sudo tee -a /etc/hosts

#sudo sed -i '/^\[Resolve\]$/a DNS=10.0.2.15:32000\nDomains=~.' /etc/systemd/resolved.conf
#sudo systemctl restart systemd-resolved

# with local certs
kubectl get secret my-secret -o jsonpath="{.data.tls\.crt}" | base64 -d > my-app.crt
#kubectl get secret my-secret -o yaml | grep tls.crt | awk '{print $2}' | base64 -d | openssl x509 -text -noout

# Add the Certificate to Your VM’s Trusted Store
# For Ubuntu/Debian:
sudo cp my-app.crt /usr/local/share/ca-certificates/my-app.crt
sudo update-ca-certificates

rm -rf my-app.crt

helm install my-app my-app/

echo "Waiting for my-app deployment to be ready..."
kubectl wait \
  --for=condition=available deployment/my-app \
  --timeout=300s
