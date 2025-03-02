## **4. Service-to-Pod Communication**

### **📌 Step-by-Step: Create a ClusterIP Service for `nginx`**  

#### **🔹 Step 1: Expose the `nginx` Pod as a ClusterIP Service**  
Run the following command to create a **ClusterIP** Service:

```sh
kubectl expose pod nginx --port=80 --target-port=80 --name=nginx-service
```
✅ Expected output:  
```
service/nginx-service exposed
```

---

#### **🔹 Step 2: Verify the Service**
Check the service details:

```sh
vagrant@vagrant:~$ kubectl get svc nginx-clusterip
NAME              TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
nginx-clusterip   ClusterIP   10.43.44.73   <none>        80/TCP    97m
vagrant@vagrant:~$ 
```
🔹 **Key Points:**
- `ClusterIP`: Internal-only service, accessible only within the cluster.
- `CLUSTER-IP`: Assigned internal IP (e.g., `10.43.44.73`).
- No `EXTERNAL-IP`: It cannot be accessed externally.

---

#### **🔹 Step 3: Test Access from `busybox`**
Now, use the `busybox` Pod to reach `nginx` via the Service
Alternatively, use the service **DNS name**:

```sh
kubectl exec -it busybox-on-master -- wget -qO- 10.43.44.73
kubectl exec -it busybox-on-master -- wget -qO- 10.43.44.73:80
kubectl exec -it busybox-on-master -- wget -qO- http://10.43.44.73
kubectl exec -it busybox-on-master -- wget -qO- nginx-clusterip
kubectl exec -it busybox-on-master -- wget -qO- nginx-clusterip:80
kubectl exec -it busybox-on-master -- wget -qO- http://nginx-clusterip
```
✅ Expected output:
```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- wget -qO- nginx-clusterip:80
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

🔹 Kubernetes **automatically** creates an internal DNS entry (`nginx-clusterip.default.svc.cluster.local`).


### **📌 Step-by-Step: Access the `nginx-service` from Another Pod**  

🔹 **How This Works:**
- Kubernetes provides **internal DNS resolution** for services.
- `nginx-service` resolves to its **ClusterIP (`10.43.44.73`)**.
- The request is routed to the `nginx` Pod.

---

#### **🔹 Step 3: Verify DNS Resolution (Optional)**
You can manually check DNS resolution inside `busybox`:

```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- nslookup nginx-clusterip
Server:		10.43.0.10
Address:	10.43.0.10:53

** server can't find nginx-clusterip.cluster.local: NXDOMAIN

Name:	nginx-clusterip.default.svc.cluster.local
Address: 10.43.44.73

** server can't find nginx-clusterip.svc.cluster.local: NXDOMAIN

** server can't find nginx-clusterip.cluster.local: NXDOMAIN


** server can't find nginx-clusterip.svc.cluster.local: NXDOMAIN

command terminated with exit code 1
vagrant@vagrant:~$ 
```

```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- nslookup nginx-clusterip.default.svc.cluster.local
Server:		10.43.0.10
Address:	10.43.0.10:53

Name:	nginx-clusterip.default.svc.cluster.local
Address: 10.43.44.73


vagrant@vagrant:~$ 
```

🔹 **Explanation:**
- `10.43.0.10` → Kubernetes **CoreDNS** handling internal DNS queries.
- `nginx-clusterip.default.svc.cluster.local` → Fully Qualified Domain Name (FQDN) of the service.
- Resolves to the assigned **ClusterIP (10.43.44.73)**.

---

### **🛠️ Troubleshooting**
1. **Service not found?**
- Ensure `nginx-clusterip` exists:  
```sh
kubectl get svc nginx-clusterip
```
- If missing, recreate it:
```sh
kubectl expose pod nginx --port=80 --target-port=80 --name=nginx-clusterip
```

2. **Busybox can't resolve service name?**
- Check CoreDNS is running:
```sh
kubectl get pods -n kube-system | grep coredns
```
- Restart `busybox` pod (sometimes busybox's DNS caching causes issues):
```sh
kubectl delete pod busybox
kubectl run busybox --image=busybox -- sleep 3600
```
