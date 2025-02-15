## Useful Commands
---

### Setting coredns svc as NodePort
---

```sh
kubectl patch svc kube-dns -n kube-system --type='merge' -p '{
  "spec": {
    "type": "NodePort",
    "ports": [
      {
        "name": "dns",
        "port": 53,
        "protocol": "UDP",
        "targetPort": 53,
        "nodePort": 32000
      },
      {
        "name": "dns-tcp",
        "port": 53,
        "protocol": "TCP",
        "targetPort": 53,
        "nodePort": 32000
      },
      {
        "name": "metrics",
        "port": 9153,
        "protocol": "TCP",
        "targetPort": 9153
      }
    ]
  }
}'
```

### Adding Certificates to VM’s Trusted Store
---

```sh
# Add the Certificate to Your VM’s Trusted Store
# For Ubuntu/Debian:
sudo cp my-app.crt /usr/local/share/ca-certificates/my-app.crt
sudo update-ca-certificates
#For RHEL/CentOS:
sudo cp my-app.crt /etc/pki/ca-trust/source/anchors/my-app.crt
sudo update-ca-trust
#For Alpine Linux:
sudo cp my-app.crt /usr/local/share/ca-certificates/my-app.crt
sudo update-ca-certificates
```
