#!/bin/bash

set -e
set -x

sudo k3s-uninstall.sh || true
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ${USER}:${USER} ~/.kube/config
