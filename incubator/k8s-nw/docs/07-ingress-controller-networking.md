## **7. Ingress Controller & External Access**

### **Deploying Nginx Ingress Controller in K3s**  

#### **Step 2: Verify Deployment**  
Check if the Ingress Controller pods are running:  
```sh
vagrant@vagrant:~$ kubectl --namespace ingress-nginx get po
NAME                                                     READY   STATUS    RESTARTS   AGE
nginx-ingress-ingress-nginx-controller-9c4d8d8fb-fmgz2   1/1     Running   0          17m
vagrant@vagrant:~$ 
```

Check if the LoadBalancer service has an external IP:  
```sh
vagrant@vagrant:~$ kubectl -n ingress-nginx get svc nginx-ingress-ingress-nginx-controller
NAME                                     TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
nginx-ingress-ingress-nginx-controller   LoadBalancer   10.43.52.53   192.168.0.108   80:30080/TCP,443:30878/TCP   18m
vagrant@vagrant:~$ 
```
- **EXTERNAL-IP**: The node’s IP (`192.168.1.100`).  
- **PORT(S)**: Port `80` and `443` are mapped to node ports.  

---

### **Creating an Ingress Resource for Nginx**  

Now that the Nginx Ingress Controller is deployed, we will define an **Ingress resource** to route traffic to the `nginx` service.

---

### **Step 3: Verify Ingress**
Check if the Ingress rule is created:  
```sh
vagrant@vagrant:~$ kubectl get ingress
NAME             CLASS   HOSTS              ADDRESS         PORTS   AGE
my-app-ingress   nginx   my-app.mitkar.io   192.168.0.108   80      18m
vagrant@vagrant:~$ 
```

---

### **Step 4: Test Access**  
Since `my-app.mitkar.io` is not a real domain, update `/etc/hosts` on your **local machine** (not inside the cluster):

```sh
sudo nano /etc/hosts
```
Add this line:
```
192.168.1.108  my-app.mitkar.io
```

Now, test access using `curl` or a browser:

```sh
curl my-app.mitkar.io
curl my-app.mitkar.io:30080
curl http://my-app.mitkar.io
```

```sh
vagrant@vagrant:~$ curl http://my-app.mitkar.io
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

```sh
curl vagrant
curl vagrant:30080
curl http://vagrant
```

```sh
vagrant@vagrant:~$ curl http://vagrant
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
vagrant@vagrant:~$ 
```
