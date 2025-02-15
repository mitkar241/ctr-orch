#!/bin/sh

set -e
set -x

#sudo sed -i '/^\[Resolve\]$/a DNS=10.0.2.15:32000\nDomains=~.' /etc/systemd/resolved.conf
#sudo systemctl restart systemd-resolved

dig my-app.mitkar.io
ping -c5 my-app.mitkar.io
openssl s_client -connect my-app.mitkar.io:443 -servername my-app.mitkar.io -showcerts </dev/null
curl https://my-app.mitkar.io
wget https://my-app.mitkar.io
rm -rf index.html

## with local certs
#kubectl get secret my-secret -o jsonpath="{.data.tls\.crt}" | base64 -d > my-app.crt
##kubectl get secret my-secret -o yaml | grep tls.crt | awk '{print $2}' | base64 -d | openssl x509 -text -noout
#curl -v --cacert my-app.crt https://my-app.mitkar.io
#wget --ca-certificate=my-app.crt https://my-app.mitkar.io
