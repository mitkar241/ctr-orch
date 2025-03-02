## **8. Debugging Kubernetes Networking**
### **8.1 Use Debugging Tools**
- **Description:** Learn how to troubleshoot network issues using `kubectl exec`, logs, and network policies.
- **Reference Material:**
  - `kubectl logs` / `kubectl describe pod`
  - `kubectl exec -it busybox -- nslookup nginx-service`
- **Definition of Done:**
  - Successfully debug a networking issue in Kubernetes.

---

### **8.1 Use Debugging Tools in Kubernetes**  

Debugging network issues in Kubernetes requires multiple tools such as `kubectl logs`, `kubectl exec`, and `kubectl describe`. We will go through **common debugging steps** and demonstrate troubleshooting a potential issue.

---

### **Step 1: Check Pod and Service Details**
Before troubleshooting, confirm that `nginx` and `busybox` pods exist and that the `nginx-service` is created.

```sh
kubectl get pods
kubectl get svc
```
If everything looks fine, proceed to network-specific debugging.

---

### **Step 2: Inspect Pod Logs**
Check if the `nginx` pod is running correctly and serving traffic.

```sh
kubectl logs <nginx-pod-name>
```
If the pod is crashing or failing, check events:
```sh
kubectl describe pod <nginx-pod-name>
```
Look for error messages related to networking or resource limits.

---

### **Step 3: Test DNS Resolution**
Inside Kubernetes, services should be accessible by name (`nginx-service`). Run an interactive session inside `busybox` and check if DNS resolution is working.

```sh
kubectl exec -it busybox -- nslookup nginx-service
```
Expected output:
```
Server:         10.43.0.10
Address:        10.43.0.10#53

Name:   nginx-service.default.svc.cluster.local
Address: 10.43.45.89
```
If this fails, **CoreDNS might be down**. Check CoreDNS logs:
```sh
kubectl get pods -n kube-system | grep coredns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

---

### **Step 4: Check Network Connectivity**
Verify if `busybox` can reach `nginx-service` over the network.

```sh
kubectl exec -it busybox -- wget -O- http://nginx-service
```
If the request fails:
- **Check Service Type** (`kubectl get svc nginx-service -o yaml`).
- **Verify Pod IP & Port** (`kubectl get pods -o wide`).
- **Check Network Policies** (`kubectl get networkpolicy -A`).

---

### **Step 5: Debug with Netcat (`nc`)**
If DNS works but connectivity fails, test if the service port is open:

```sh
kubectl exec -it busybox -- nc -zv nginx-service 80
```
- If `succeeded`, the connection works.
- If `failed`, the service or network policies may be blocking traffic.

---

### **Step 6: Check Iptables Rules on the Node**
Since K3s uses **iptables** for networking, list the relevant NAT and forwarding rules:

```sh
sudo iptables -t nat -L -n -v | grep KUBE
sudo iptables -L -n -v | grep KUBE
```

---

### **Definition of Done ✅**
✔ Checked Pod logs (`kubectl logs`).  
✔ Verified DNS resolution (`nslookup`).  
✔ Tested connectivity (`wget`, `nc`).  
✔ Inspected Network Policies and `iptables` rules.  

Let me know if you want to simulate a real networking failure scenario! 🚀

---

## **Advanced Kubernetes Network Debugging Tactics & Tools**  

When things go wrong in Kubernetes networking, you need solid troubleshooting skills. Below are some **powerful debugging techniques** using built-in Kubernetes tools and external utilities.

---

## **1️⃣ Basic Debugging Tools**
### **1.1 Check Pod and Service Status**
- Ensure all Pods and Services exist and are running:
  ```sh
  kubectl get pods -o wide
  kubectl get svc -o wide
  ```
- If a Pod is **not running**, inspect its status:
  ```sh
  kubectl describe pod <pod-name>
  ```
- If a Service is **not accessible**, check its details:
  ```sh
  kubectl describe svc <service-name>
  ```

---

## **2️⃣ Debugging DNS Issues**
### **2.1 Verify CoreDNS is Running**
DNS failures can prevent services from resolving.

```sh
kubectl get pods -n kube-system | grep coredns
```
If CoreDNS is down, restart it:
```sh
kubectl rollout restart deployment coredns -n kube-system
```

### **2.2 Test DNS Resolution Inside a Pod**
Run an interactive `busybox` pod and check if DNS resolution works:

```sh
kubectl exec -it busybox -- nslookup nginx-service
kubectl exec -it busybox -- dig nginx-service
kubectl exec -it busybox -- getent hosts nginx-service
```
If this fails, check **CoreDNS logs**:
```sh
kubectl logs -n kube-system -l k8s-app=kube-dns
```

---

## **3️⃣ Network Connectivity Debugging**
### **3.1 Test Connectivity Between Pods**
Use `ping` to verify if two Pods can reach each other (only works if ICMP is not blocked):

```sh
kubectl exec -it busybox -- ping -c 4 <nginx-pod-ip>
```
If `ping` fails:
- The Pod might be in a different **NetworkPolicy-restricted namespace**.
- The Pod IP might have changed; verify with `kubectl get pods -o wide`.

### **3.2 Test Port Connectivity Using `nc` (Netcat)**
```sh
kubectl exec -it busybox -- nc -zv nginx-service 80
```
- If **succeeded**, the connection is open.
- If **failed**, a firewall rule or network policy is blocking access.

### **3.3 Check Kubernetes Proxy Rules**
Kubernetes `kube-proxy` manages Service routing via `iptables`. To inspect the NAT rules:

```sh
sudo iptables -t nat -L -n -v | grep KUBE
```
If you suspect a misconfiguration, restart `kube-proxy`:
```sh
kubectl delete pod -n kube-system -l k8s-app=kube-proxy
```

---

## **4️⃣ Network Policies Debugging**
Kubernetes NetworkPolicies can block inter-Pod communication.

### **4.1 Check Existing Network Policies**
```sh
kubectl get networkpolicy -A
```
If a policy is blocking traffic, allow communication using:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: busybox
    ports:
    - protocol: TCP
      port: 80
```
Apply it using:
```sh
kubectl apply -f allow-nginx.yaml
```

---

## **5️⃣ Inspecting LoadBalancer Traffic**
If an external LoadBalancer (e.g., `klipper-lb`) isn't routing traffic:

### **5.1 Check LoadBalancer Service**
```sh
kubectl get svc nginx-loadbalancer -o wide
```
- If **External IP is `<pending>`**, K3s hasn't assigned an IP.
- If assigned, verify it's reachable:
  ```sh
  curl http://<loadbalancer-ip>
  ```
  
### **5.2 Inspect `svclb` Pods (Klipper LoadBalancer)**
```sh
kubectl get pods -n kube-system | grep svclb
kubectl logs -n kube-system svclb-nginx-loadbalancer-<pod>
```

---

## **6️⃣ Checking K3s & Flannel Network Issues**
K3s uses **Flannel** as the default CNI. To debug:

### **6.1 Check Flannel Logs**
```sh
kubectl logs -n kube-system -l app=flannel
```
If Flannel isn't running:
```sh
kubectl rollout restart daemonset -n kube-system flannel
```

### **6.2 Inspect Flannel Network Interfaces**
Run the following inside a Node:
```sh
ip addr show flannel.1
ip route
```

---

## **7️⃣ Node-Level Debugging**
### **7.1 Verify K3s Node Health**
```sh
kubectl get nodes -o wide
```
If a node is `NotReady`, check:
```sh
kubectl describe node <node-name>
```

### **7.2 Check Node-Level Firewalls**
If certain ports are blocked, inspect `iptables` rules:
```sh
sudo iptables -L -n -v | grep KUBE
```

---

## **8️⃣ External Tools for Network Debugging**
### **8.1 Using `tcpdump` for Packet Capture**
If deep analysis is required, install `tcpdump` on a Node and capture traffic:

```sh
sudo tcpdump -i eth0 port 80
```

### **8.2 Using `wireshark`**
Export captured traffic from `tcpdump` and analyze in Wireshark.

---

## **Conclusion**
✅ **DNS Issues?** → Check `CoreDNS`, `nslookup`, `kubectl logs`.  
✅ **Pod Connectivity Issues?** → Use `ping`, `nc`, `iptables`.  
✅ **Service Issues?** → Verify `kube-proxy`, `iptables -t nat -L -n -v`.  
✅ **Network Policy Blocks?** → `kubectl get networkpolicy -A`.  
✅ **LoadBalancer Issues?** → Inspect `svclb` pods, restart Flannel.  

Would you like to test a **real network failure scenario** and debug it? 🚀
