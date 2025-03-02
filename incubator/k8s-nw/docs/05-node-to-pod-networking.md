## **5. Node-to-Pod Communication (NodePort Service)**

### **📌 Step-by-Step: Create a NodePort Service for `nginx`**  

#### **🔹 Step 1: Create the NodePort Service**
Run the following command to expose the `nginx` pod as a **NodePort** service:

```sh
kubectl expose pod nginx --type=NodePort --port=80 --target-port=80 --name=nginx-nodeport
```

✅ **What This Does:**
- Exposes the `nginx` pod externally.
- Assigns a **high-range port (30000-32767)** on every node.
- Traffic to this port is forwarded to the `nginx` pod on **port 80**.

---

#### **🔹 Step 2: Verify the NodePort Service**
Check that the service was created successfully:

```sh
vagrant@vagrant:~$ kubectl get svc nginx-nodeport
NAME             TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
nginx-nodeport   NodePort   10.43.49.92   <none>        80:30070/TCP   113m
vagrant@vagrant:~$ 
```

🔹 **Breakdown of Output:**
- `TYPE`: **NodePort** (exposes the service externally).
- `CLUSTER-IP`: **10.43.250.12** (internal service IP).
- `PORT(S)`: **80:30070/TCP**
  - **80** → The port inside the cluster.
  - **30070** → The automatically assigned **NodePort** (varies between **30000-32767**).

---

#### **🔹 Step 3: Access `nginx` Using NodePort**
You can now access `nginx` from **outside the cluster** using any **node's IP** and the assigned NodePort.

1️⃣ **Find the Node’s IP Address:**
```sh
vagrant@vagrant:~$ kubectl get nodes -o wide
NAME      STATUS   ROLES                  AGE     VERSION        INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
vagrant   Ready    control-plane,master   3h48m   v1.31.6+k3s1   192.168.0.108   <none>        Ubuntu 20.04.6 LTS   5.4.0-208-generic   containerd://2.0.2-k3s2
vagrant@vagrant:~$ 
```
**Internal IP**: `192.168.1.108` (this will be your node’s IP).

---

2️⃣ **Access `nginx` Using `curl` or Browser:**
```sh
vagrant@vagrant:~$ curl 192.168.0.108:30070
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
vagrant@vagrant:~$ 
```

---

### **🛠️ NodePorts in netstat**

```sh
vagrant@vagrant:~$ sudo netstat -tulpn | grep 300
vagrant@vagrant:~$ 
```

Kubernetes services are not implemented as processes listening on a specific port. Instead iptables (or IPVS) is used and services are basically iptables rules. That's why they won't show up in your netstat. You can find more info about it here: https://kubernetes.io/docs/concepts/services-networking/service/#proxy-mode-iptables .

---

### **🛠️ Troubleshooting**
1. **Service not found?**
   - Ensure `nginx-nodeport` exists:
     ```sh
     kubectl get svc nginx-nodeport
     ```
   - If missing, recreate it:
     ```sh
     kubectl expose pod nginx --type=NodePort --port=80 --target-port=80 --name=nginx-nodeport
     ```

2. **Port not accessible?**
   - Ensure the node's firewall allows traffic on the assigned **NodePort** (e.g., `30070`):
     ```sh
     sudo iptables -L -n -v | grep 30070
     ```
   - If blocked, allow it:
     ```sh
     sudo iptables -A INPUT -p tcp --dport 30070 -j ACCEPT
     ```

3. **Can't reach from external network?**
   - If running Kubernetes inside a VM, use **port forwarding** to expose `30070` externally.
