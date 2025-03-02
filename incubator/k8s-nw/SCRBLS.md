# Scribbles
---

```sh
hostnamectl set-hostname worker

# replace `vagrant` entry in worker node to `worker`

cat > /etc/hosts
192.168.0.108   vagrant
192.168.0.109   worker

vagrant@worker:~$ curl -k https://192.168.0.108:6443/healthz
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}

sudo systemctl restart k3s-agent.service
```
