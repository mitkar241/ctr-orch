#!/bin/sh

set -e
set -x

grep -Pq "^\s*192\.168\.0\.108\s+my-app\.mitkar\.io\b" /etc/hosts || echo "192.168.0.108 my-app.mitkar.io" | sudo tee -a /etc/hosts

helm install my-app my-app/

#echo "Waiting for my-app deployment to be ready..."
#kubectl wait \
#  --for=condition=available deployment/my-app \
#  --timeout=300s
