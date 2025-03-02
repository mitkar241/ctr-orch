## **3. Pod-to-Pod Communication**

### **🚀 Deploying Two Standalone Pods**  

Now, we’ll deploy **two separate Pods**:  
1️⃣ **Nginx Pod** 🖥 (Web Server)  
2️⃣ **BusyBox Pod** 🛠 (Lightweight Utility Container)  

This time, **they won’t be in the same Pod**, meaning they do **not share the same network namespace** like in the previous exercise.  

---

### **🚀 Testing Pod-to-Pod Communication Without a Service**  

Since our `nginx` and `busybox` Pods are **not in the same Pod**, they do **not** share a network namespace. However, they can still communicate via their **Pod IPs**, thanks to Kubernetes' **flat networking model**.

---

## **📌 Steps to Test Communication**

### **1️⃣ Get the Nginx Pod's IP**
Run:

```sh
vagrant@vagrant:~$ kubectl get po -o wide
NAME                READY   STATUS    RESTARTS   AGE   IP          NODE      NOMINATED NODE   READINESS GATES
busybox-on-master   1/1     Running   0          19m   10.42.0.5   vagrant   <none>           <none>
nginx-on-master     2/2     Running   0          19m   10.42.0.7   vagrant   <none>           <none>
vagrant@vagrant:~$ 
```
- **Nginx IP:** `10.42.0.7`
- **BusyBox IP:** `10.42.0.5`

---

### **2️⃣ Use BusyBox to Access Nginx via Pod IP**
Run the following command to exec into the `busybox` Pod

Now, inside the BusyBox shell, **test the connection using `wget`**:

```sh
kubectl exec -it busybox-on-master -- wget -qO- http://10.42.0.7
kubectl exec -it busybox-on-master -- wget -qO- 10.42.0.7:80
kubectl exec -it busybox-on-master -- wget -qO- 10.42.0.7
```

✅ Expected Output:
```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- wget -qO- 10.42.0.7:80
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

This confirms that **BusyBox successfully reached Nginx** over the Pod IP.

---

## **🔎 Explanation**
- **Pods in Kubernetes can communicate directly via Pod IPs** even without a Service.
- This works because Kubernetes **creates a flat, NAT-less network**, where each Pod gets a unique **IP address** that is routable within the cluster.

---

Let's **visualize and prove** that each Pod gets a **unique IP address** and that it is **routable** within the cluster.

---

### **🔍 1️⃣ Check Pod IPs**
Run:

```sh
vagrant@vagrant:~$ kubectl get po -o wide
NAME                READY   STATUS    RESTARTS   AGE   IP          NODE      NOMINATED NODE   READINESS GATES
busybox-on-master   1/1     Running   0          19m   10.42.0.5   vagrant   <none>           <none>
nginx-on-master     2/2     Running   0          19m   10.42.0.7   vagrant   <none>           <none>
vagrant@vagrant:~$ 
```
- **Nginx IP:** `10.42.0.7`
- **BusyBox IP:** `10.42.0.5`

- Each **Pod** has a **unique IP**.
- These IPs are **assigned by the CNI plugin** (Flannel in our case).
- They are **not externally routable** (not accessible from outside the cluster), but **they work within the cluster**.

---

### **🔎 2️⃣ Verify IP Routes in the Host (K3s Node)**
Run on your K3s node:

```sh
vagrant@vagrant:~$ ip route | grep 10.42
10.42.0.0/24 dev cni0 proto kernel scope link src 10.42.0.1 
vagrant@vagrant:~$ 
```
- This shows that **traffic for 10.42.0.0/24 (Pod network)** is routed through `cni0`, the CNI bridge.
- This means **all Pods within this range can reach each other directly**.

---

### **🛠 3️⃣ Test Pod-to-Pod Connectivity Using `ping`**
Exec into `busybox`:

Now, **ping the `nginx` Pod**:

```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- ping -c 4 10.42.0.7
PING 10.42.0.7 (10.42.0.7): 56 data bytes
64 bytes from 10.42.0.7: seq=0 ttl=64 time=0.806 ms
64 bytes from 10.42.0.7: seq=1 ttl=64 time=0.142 ms
64 bytes from 10.42.0.7: seq=2 ttl=64 time=0.131 ms
64 bytes from 10.42.0.7: seq=3 ttl=64 time=0.162 ms

--- 10.42.0.7 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.131/0.310/0.806 ms
vagrant@vagrant:~$ 
```
- **Packets are successfully reaching the Nginx Pod**, proving that the Pod IPs are **routable within the cluster**.

---

### **📌 4️⃣ Verify Network Interfaces Inside a Pod**
Now, let's see the network interface inside the `busybox` Pod:

```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0@if16: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue qlen 1000
    link/ether 7a:a6:05:2d:69:33 brd ff:ff:ff:ff:ff:ff
    inet 10.42.0.5/24 brd 10.42.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::78a6:5ff:fe2d:6933/64 scope link 
       valid_lft forever preferred_lft forever
vagrant@vagrant:~$ 
```
- **eth0** is the primary network interface for the Pod.
- It has an IP (`10.42.0.5`), which matches the **Pod IP** from `kubectl get pods -o wide`.
- This interface allows the Pod to **communicate with other Pods in the cluster**.

---

### **🛠 5️⃣ Confirm Routing Table Inside a Pod**
Exec into `busybox` again:

Check the **routing table**:

```sh
vagrant@vagrant:~$ kubectl exec -it busybox-on-master -- ip r
default via 10.42.0.1 dev eth0 
10.42.0.0/24 dev eth0 scope link  src 10.42.0.5 
10.42.0.0/16 via 10.42.0.1 dev eth0 
vagrant@vagrant:~$ 
```

- The default route goes through `10.42.0.1` (CNI bridge `cni0`).
- The Pod has a **direct route to the 10.42.0.0/24 network**, allowing it to reach other Pods.

```sh
vagrant@vagrant:~$ ifconfig cni0
cni0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 10.42.0.1  netmask 255.255.255.0  broadcast 10.42.0.255
        inet6 fe80::7cf4:dcff:fe91:76d9  prefixlen 64  scopeid 0x20<link>
        ether 7e:f4:dc:91:76:d9  txqueuelen 1000  (Ethernet)
        RX packets 115007  bytes 22148758 (22.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 125367  bytes 13375841 (13.3 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vagrant@vagrant:~$ 
```

---

### **🔎 Conclusion**
✔ **Each Pod has a unique IP assigned from the Pod network (`10.42.0.0/16`).**  
✔ **Pods communicate directly via these IPs without NAT.**  
✔ **The CNI (`cni0` bridge) enables routing within the cluster.**  
✔ **Pod-to-Pod communication works using standard network routing.**  

---

### **🔍 Understanding `eth0@if16`**
When you run `ip a` inside a Pod, you see something like:

```sh
vagrant@vagrant:~$ ip a
...
16: veth4869ce8a@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether ee:21:38:4e:f4:c8 brd ff:ff:ff:ff:ff:ff link-netns cni-00bf1dfc-ebb6-d22b-6a21-ef6104d0465f
    inet6 fe80::ec21:38ff:fe4e:f4c8/64 scope link 
       valid_lft forever preferred_lft forever
...
```

The key part: `eth0@if16`  

This means:  
- `eth0` is the **main network interface** inside the Pod.
- `@if16` indicates that `eth0` is **linked to interface index 16** on the **host (K3s node)**.  

---

### **🔗 What is `if16`?**
- **`if16` is an interface index** on the host machine (K3s node).  
- **It's a Virtual Ethernet (veth) pair** that connects the Pod’s `eth0` to the host.  
- **The host side of this connection is named `vethXXXXX` (visible on the node).**

---

### **🔎 How Does This Work?**
1. **Kubernetes (via the CNI plugin)** creates a **veth pair** when starting a Pod.
2. One end of the veth pair (`vethXXXXX`) is attached to the host’s network (typically the `cni0` bridge).
3. The other end is placed inside the Pod and renamed `eth0`.
4. The `@if16` notation means **eth0 is linked to interface index 5 on the host**.

---

### **📌 Key Takeaways**
✔ **`eth0@if16` means the Pod's `eth0` is connected to host interface index 16**  
✔ **This is done using a veth pair (one inside the Pod, one on the host)**  
✔ **The host-side veth interface is connected to `cni0`, enabling Pod-to-Pod communication**  
