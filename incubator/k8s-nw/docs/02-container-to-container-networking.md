## **2. Container-to-Container Communication (Same Pod)**
---

### **🚀 Deploying a Multi-Container Pod in K3s**  

In this step, we'll deploy a **single Pod** that contains **two containers**:  
1. **Nginx** (serves HTTP traffic)  
2. **BusyBox** (executes a loop to log messages)  

This setup is useful when containers need to **share resources** like volumes or communicate via `localhost`.

---

### **🔎 Test Communication Between Containers**
#### **1️⃣ Exec into BusyBox and Curl Nginx**
```sh
vagrant@vagrant:~$ kubectl exec -it nginx-on-master -c busybox -- wget -qO- localhost:80
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
This confirms that **BusyBox can reach Nginx** inside the same Pod.

---

### **🚀 Testing Localhost Communication in a Multi-Container Pod**  

Now that we have a **multi-container Pod** running with **Nginx** and **BusyBox**, let's verify that **BusyBox can communicate with Nginx via `localhost`**.  

---

### **📌 Why Does This Work?**
- **Containers in the same Pod share the same network namespace.**  
- They communicate using `localhost` since both run **on the same virtual network stack**.  
- **Nginx listens on port `80`**, and BusyBox can reach it as if it were running in the same container.

---

### **🛠 Troubleshooting**

If `curl` or `wget` fails:

1. **Check if the Pod is running:**
```sh
vagrant@vagrant:~$ kubectl get po nginx-on-master
NAME              READY   STATUS    RESTARTS   AGE
nginx-on-master   2/2     Running   0          14m
vagrant@vagrant:~$ 
```
Ensure the status is `Running` with `2/2` containers ready.

2. **Check Nginx logs:**
```sh
vagrant@vagrant:~$ kubectl logs -f nginx-on-master -c nginx
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/03/02 08:38:58 [notice] 1#1: using the "epoll" event method
2025/03/02 08:38:58 [notice] 1#1: nginx/1.27.4
2025/03/02 08:38:58 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2025/03/02 08:38:58 [notice] 1#1: OS: Linux 5.4.0-208-generic
2025/03/02 08:38:58 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2025/03/02 08:38:58 [notice] 1#1: start worker processes
2025/03/02 08:38:58 [notice] 1#1: start worker process 29
2025/03/02 08:38:58 [notice] 1#1: start worker process 30
2025/03/02 08:38:58 [notice] 1#1: start worker process 31
2025/03/02 08:38:58 [notice] 1#1: start worker process 32
127.0.0.1 - - [02/Mar/2025:08:42:45 +0000] "GET / HTTP/1.1" 200 615 "-" "Wget" "-"
```
If no logs appear, Nginx might not be receiving requests.

3. **Verify Nginx is listening on port 80:**
```sh
vagrant@vagrant:~$ kubectl exec -it nginx-on-master -c busybox -- netstat -tulnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -
tcp        0      0 :::80                   :::*                    LISTEN      -
vagrant@vagrant:~$ 
```
