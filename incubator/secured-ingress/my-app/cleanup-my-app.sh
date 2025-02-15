#!/bin/sh

set -e
set -x

helm uninstall my-app

sudo sed -i '/^\s*10\.0\.2\.15\s\+my-app\.mitkar\.io\b/d; /^\s*$/d' /etc/hosts

#sudo sed -i '/^\[Resolve\]$/a DNS=10.0.2.15:32000\nDomains=~.' /etc/systemd/resolved.conf
#sudo systemctl restart systemd-resolved

# Delete the Certificate to Your VM’s Trusted Store
sudo rm -rf /usr/local/share/ca-certificates/my-app.crt
sudo update-ca-certificates
