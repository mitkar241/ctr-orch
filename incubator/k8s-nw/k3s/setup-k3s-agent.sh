#!/bin/bash

set -e
set -x

echo "execute `make setup-k3s-agent` in master node to get command to register agent"

K3S_URL="https://$(hostname -I | cut -d ' ' -f1)"
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/token)
echo "curl -sfL https://get.k3s.io | K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} sh -"

#systemctl status k3s-agent.service
