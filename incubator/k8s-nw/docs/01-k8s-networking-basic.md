## **1. Basics of Kubernetes Networking**
### **1.1 Understand Kubernetes Networking Model**
- **Description:** Learn about how Kubernetes networking enables Pod-to-Pod communication without NAT and supports dynamic scaling.
- **Reference Material:**
  - [Kubernetes Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
  - [Kubernetes CNI Documentation](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- **Definition of Done:**
  - Understand flat networking concept in Kubernetes.
  - Explain why there’s no NAT inside the cluster.

### **1.2 Study Container Network Interface (CNI) in K3s**
- **Description:** Learn how K3s uses Flannel or another CNI plugin to enable Pod networking.
- **Reference Material:**
  - [Flannel CNI](https://github.com/flannel-io/flannel)
  - `kubectl get pods -n kube-flannel | grep flannel`
- **Definition of Done:**
  - Identify which CNI plugin is running in K3s.
  - Describe how it facilitates Pod networking.

---

#### **1. What is NAT (Network Address Translation)?**
- **NAT (Network Address Translation)** is a technique used in networking to modify IP address information in packet headers while in transit.
- It is commonly used when multiple devices share a single public IP address (e.g., in home routers).
- In traditional networking, NAT allows private IPs to communicate with the internet by mapping them to a public IP.

#### **2. What is a Pod in Terms of Networking?**
- A **Pod** is the smallest deployable unit in Kubernetes, consisting of one or more containers.
- Each Pod has its **own unique IP address**, assigned by the Kubernetes network.
- **All containers within a Pod share the same network namespace**:
  - They communicate via `localhost`.
  - They share the same IP address.
- Pods can communicate with other Pods **directly using their IP addresses**, without NAT.

---

#### **3. What is Dynamic Scaling?**
- **Dynamic scaling** refers to Kubernetes' ability to **automatically add or remove Pods** based on workload demand.
- Scaling is handled by:
  - **Horizontal Pod Autoscaler (HPA)** – adjusts the number of running Pods.
  - **Cluster Autoscaler** – adjusts the number of nodes in the cluster.
- Example:
  - If traffic increases, Kubernetes can **scale up** by creating more Pods.
  - If traffic decreases, Kubernetes can **scale down** by removing unnecessary Pods.

---

#### **4. What is the Flat Networking Concept?**
- **Flat networking** means **all Pods in the cluster can communicate with each other without NAT or additional routing**.
- This is different from traditional networking, where separate networks require NAT or routing rules.
- Kubernetes networking **ensures every Pod gets a unique IP that is routable across the cluster**.

---

### **Key Takeaways**
✅ Kubernetes assigns a **unique routable IP** to each Pod.  
✅ Pods **communicate directly** without NAT.  
✅ The network remains **flat**, meaning no additional configurations are needed for Pod-to-Pod communication.  
✅ **Dynamic scaling** ensures Kubernetes can add/remove Pods based on demand.  

Let me know if any part needs deeper explanation! 🚀

---

### **Reference Materials for Your Questions**

#### **1. NAT (Network Address Translation)**
- 📖 [NAT Explanation - Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-nat/)
- 📖 [Network Address Translation (NAT) - Cisco](https://www.cisco.com/c/en/us/solutions/enterprise-networks/what-is-nat.html)
- 📖 [How NAT Works - IETF RFC 3022](https://datatracker.ietf.org/doc/html/rfc3022)

#### **2. Pod Networking in Kubernetes**
- 📖 [Kubernetes Pods Overview](https://kubernetes.io/docs/concepts/workloads/pods/)
- 📖 [How Kubernetes Assigns Pod IPs](https://kubernetes.io/docs/concepts/cluster-administration/networking/#pod-to-pod-communication)
- 📖 [Kubernetes Networking Deep Dive - Official Docs](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

#### **3. Dynamic Scaling in Kubernetes**
- 📖 [Kubernetes Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- 📖 [Cluster Autoscaler - Kubernetes Docs](https://kubernetes.io/docs/tasks/administer-cluster/cluster-management/#cluster-autoscaler)
- 📖 [Kubernetes Scaling Strategies](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler)

#### **4. Flat Networking Concept in Kubernetes**
- 📖 [Kubernetes Networking Model](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- 📖 [CNI Plugins and Kubernetes Networking](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- 📖 [Why Kubernetes Uses a Flat Network - Medium Article](https://itnext.io/kubernetes-networking-from-basics-to-advanced-level-part-1-9a6c537f2aa2)

---

## **1. What is CNI (Container Network Interface)?**  
CNI (**Container Network Interface**) is a **standardized specification** that defines how networking should be configured for **containers in a Kubernetes cluster**.  

### **Key Points About CNI**  
✅ **CNI is a set of specifications & libraries** that define how network connectivity is provided to containers.  
✅ **CNI plugins** are responsible for **creating, attaching, and managing networking for Pods**.  
✅ **CNI plugins handle IP address allocation, routing, and network policies**.  

📖 **Reference:**  
- [CNI Specification - GitHub](https://github.com/containernetworking/cni)  
- [Kubernetes CNI Documentation](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)  

---

## **2. What is KNI (Kernel Network Interface) in Ubuntu?**  
KNI (**Kernel Network Interface**) is a **Linux kernel-level networking mechanism** that handles network operations **between user-space applications and the network stack**.  

### **Key Points About KNI in Ubuntu**  
✅ **KNI is commonly used for high-performance packet processing**, especially in **DPDK (Data Plane Development Kit)** environments.  
✅ **Unlike CNI, KNI is more focused on direct network access for user-space applications** rather than container networking.  
✅ **Linux bridge, iptables, and networking stack** interact with KNI at the kernel level.  

📖 **Reference:**  
- [Kernel Network Stack in Linux](https://www.kernel.org/doc/html/latest/networking/index.html)  
- [Linux Kernel Network Interfaces Overview](https://www.redhat.com/sysadmin/linux-network-interfaces)  

---

## **3. How Do CNI and KNI Relate to Each Other in the Current Context?**  
🔗 **CNI (Container Network Interface) operates at the container level, while KNI (Kernel Network Interface) operates at the Linux kernel level.**  

- **CNI plugins** (like Flannel, Calico) configure networking for Pods **above the Linux networking stack**.  
- **KNI operates inside the Linux kernel**, handling packet transmission, bridging, and routing at the system level.  
- **CNI plugins ultimately rely on the Linux kernel’s networking stack (which includes KNI)** for implementing their networking functionality.  

### **How They Interact in Kubernetes (K3s on Ubuntu)?**  
1. **CNI plugin (e.g., Flannel) assigns an IP to the Pod** and configures routing rules.  
2. **Linux Kernel (KNI) processes network packets, handles IP routing, and applies firewall rules (iptables/nftables).**  
3. **CNI plugins configure kernel networking components** (e.g., creating virtual Ethernet interfaces, setting up routes).  

---

## **4. What is a CNI Plugin?**
A **CNI Plugin** is a **specific implementation** of the CNI specification that provides **network connectivity to Kubernetes Pods**.  

### **Examples of CNI Plugins:**
1. **Flannel** – Uses an overlay network for Pod-to-Pod communication.  
2. **Calico** – Uses native Linux routing and provides network security policies.  
3. **Cilium** – Uses eBPF for advanced networking and security.  
4. **Weave** – Implements a decentralized network mesh for Pods.  

📖 **Reference:**  
- [Flannel CNI](https://github.com/flannel-io/flannel)  
- [Calico CNI](https://www.projectcalico.org/)  
- [Cilium CNI](https://cilium.io/)  

---

## **5. Why Does Kubernetes Need a CNI Plugin to Enable Pod Networking?**  
Without a CNI plugin, **Kubernetes does not have a built-in way to connect Pods together**.  

### **Why Kubernetes Needs a CNI Plugin?**
🚀 **CNI handles IP assignment and routing** – Kubernetes does not do this on its own.  
🚀 **Kubernetes expects each Pod to have a unique IP** – CNI ensures this happens correctly.  
🚀 **Pod-to-Pod communication requires networking rules** – CNI plugins configure this dynamically.  
🚀 **CNI plugins integrate with the underlying Linux networking** (KNI, iptables, routes).  

Without a CNI plugin, **Pods would not be able to communicate across nodes**, making Kubernetes networking non-functional.  

📖 **Reference:**  
- [Kubernetes Networking Model](https://kubernetes.io/docs/concepts/cluster-administration/networking/)  

---

### **Key Takeaways**
✅ **CNI = Network solution for containers (Kubernetes level), KNI = Network system in Linux (Kernel level).**  
✅ **CNI Plugins (Flannel, Calico, Cilium) implement networking for Kubernetes Pods.**  
✅ **CNI relies on the Linux Kernel (KNI) for packet forwarding, routing, and firewalling.**  
✅ **Kubernetes requires a CNI plugin to provide Pod networking, as it does not do this by itself.**  

---

We'll run **commands to inspect network settings**, visualize **CNI behavior**, and see how the **Linux kernel (KNI) interacts with Kubernetes networking**.

---

## **1️⃣ Identify the CNI Plugin in K3s**
Since K3s **bundles a CNI plugin by default**, we need to check which one is running.

```sh
kubectl get pods -n kube-flannel | grep flannel
```
✅ **Expected Output:** If K3s is using Flannel, you will see a pod like:  
```
kube-flannel-ds-abcdef   1/1   Running   0   2m
```
If no Flannel pod is running, **check if another CNI is active:**
```sh
kubectl get pods -n kube-system
```
Look for **Calico, Cilium, Weave, or other CNI-related pods**.

---

## **2️⃣ Check Pod Network Configuration**
### **2.1 List All Pods and Their IPs**
```sh
kubectl get pods -A -o wide
```
✅ **Expected Output:**  
This shows **Pod IP addresses** assigned by the CNI. Example:
```
NAMESPACE   NAME            POD IP       NODE
default     my-app          10.42.1.10   k3s-node1
kube-system coredns-xyz     10.42.0.5    k3s-node1
```
📌 **Pod IPs belong to the Pod network created by the CNI.**

---

## **3️⃣ View Node Network Interfaces**
K3s uses the **underlying Linux networking stack** to create virtual interfaces. Let's inspect them.

```sh
ip a
```
✅ **Expected Output:**
You'll see multiple interfaces. Example:
```
flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950 qdisc noqueue state UNKNOWN
    inet 10.42.0.1/32 scope global flannel.1
cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.42.0.1/24 scope global cni0
```
📌 **`flannel.1`** → Flannel's virtual interface for overlay networking  
📌 **`cni0`** → Kubernetes bridge for Pods on this node  

---

## **4️⃣ View CNI Routing Rules**
Kubernetes **automatically manages IP routes** to connect Pods across nodes.

```sh
ip route
```
✅ **Expected Output (Flannel example):**
```
default via 192.168.1.1 dev eth0
10.42.0.0/24 dev cni0 proto kernel scope link src 10.42.0.1
10.42.1.0/24 via 192.168.1.2 dev flannel.1
```
📌 **`10.42.0.0/24 dev cni0`** → Local Pod network on this node  
📌 **`10.42.1.0/24 via 192.168.1.2 dev flannel.1`** → Routing to another node via Flannel  

---

## **5️⃣ Check How CNI Manages IP Addresses**
Each Pod gets an **IP assigned by CNI**. Let’s inspect the IP allocations.

```sh
cat /var/lib/cni/networks/cni0/*
```
✅ **Expected Output:**  
A list of assigned Pod IPs.

---

## **6️⃣ Check How KNI Handles Kubernetes Traffic**
The **Linux kernel (KNI)** manages network rules for Kubernetes. Let’s inspect them.

### **6.1 View IP Tables Rules**
```sh
iptables -L -v -n
```
✅ **Expected Output:**  
Lists firewall rules applied to Pod traffic.

### **6.2 View NAT Rules for Pod Traffic**
```sh
iptables -t nat -L -v -n
```
✅ **Expected Output:**  
Shows how Kubernetes **masquerades Pod IPs when accessing external networks**.

---

## **7️⃣ Verify Pod-to-Pod Communication**
To test **direct Pod-to-Pod connectivity**, run:

### **7.1 Create Two Test Pods**
```sh
kubectl run pod1 --image=busybox --restart=Never -- sleep 3600
kubectl run pod2 --image=busybox --restart=Never -- sleep 3600
```
### **7.2 Get Their IPs**
```sh
kubectl get pods -o wide
```
✅ **Expected Output:**  
Example:
```
NAME    READY   STATUS    POD IP       NODE
pod1    1/1     Running   10.42.1.2    k3s-node1
pod2    1/1     Running   10.42.1.3    k3s-node1
```
### **7.3 Test Connectivity Between Pods**
```sh
kubectl exec pod1 -- ping -c 3 10.42.1.3
```
✅ **Expected Output:**  
```
PING 10.42.1.3 (10.42.1.3): 56 data bytes
64 bytes from 10.42.1.3: icmp_seq=1 ttl=64 time=0.084 ms
```
📌 **Pods can communicate directly because Kubernetes provides a flat network (no NAT needed).**

---

## **🛠 Summary of Findings**
| **Test** | **Command** | **Purpose** |
|----------|------------|-------------|
| Check CNI Plugin | `kubectl get pods -n kube-system | grep flannel` | See if Flannel or another CNI is running |
| Get Pod IPs | `kubectl get pods -A -o wide` | See how Pods get IPs |
| View Network Interfaces | `ip a` | Check Flannel and CNI interfaces |
| View Routing Rules | `ip route` | See how Pod traffic is routed |
| Check Pod IP Assignments | `cat /var/lib/cni/networks/cni0/*` | Find which IPs are assigned to Pods |
| Inspect IPTables Rules | `iptables -L -v -n` | See firewall rules applied to Pod traffic |
| Verify NAT Rules | `iptables -t nat -L -v -n` | Check how external traffic is handled |
| Pod-to-Pod Connectivity | `kubectl exec pod1 -- ping -c 3 <pod2-IP>` | Confirm direct Pod communication |

---

### **🚀 Next Steps**
Would you like to:
1. **Test Pod-to-Service communication?**  
2. **Explore external traffic flow (NodePort, LoadBalancer)?**  
3. **Deep dive into DNS resolution in Kubernetes?**  

Let me know how you want to proceed! 🎯

---

Your **K3s cluster is running**, but **no Flannel or other CNI plugin pods** are listed in `kube-system`.  

### **Possible Reasons:**
1. **Flannel is running as an internal process** instead of a separate pod.  
   - K3s **bundles Flannel directly into `k3s server`**, so it may not show up in `kubectl get pods -n kube-system`.

2. **K3s is using a different CNI** or is running in a mode that doesn't require a separate CNI pod.

---

### **🔍 Verify the CNI in Use**
#### **1️⃣ Check K3s Server Logs**
```sh
sudo journalctl -u k3s | grep 'CNI'
```
✅ **Expected Output (if Flannel is used):**
```
Using CNI plugin: flannel
```
If Flannel isn’t mentioned, look for `calico`, `cilium`, or `weave`.

---

#### **2️⃣ Check Active Network Interfaces**
```sh
ip a
```
✅ **Expected Output (if Flannel is active):**
Look for **`flannel.1`** and **`cni0`** interfaces. Example:
```
flannel.1: <BROADCAST,MULTICAST,UP> mtu 8950
    inet 10.42.0.1/32 scope global flannel.1
cni0: <BROADCAST,MULTICAST,UP> mtu 1500
    inet 10.42.0.1/24 scope global cni0
```
- **`flannel.1`**: Overlay network for inter-node communication  
- **`cni0`**: Local Pod bridge  

If these are missing, **Flannel may not be running.**

---

#### **3️⃣ Check Pod Networking Details**
```sh
kubectl get pods -A -o wide
```
- Look at **POD IPs** (e.g., `10.42.x.x`). If they exist, Flannel or another CNI is working.

---

#### **4️⃣ Check Flannel Configuration File (if present)**
```sh
sudo cat /var/lib/rancher/k3s/agent/etc/flannel/net-conf.json
```
✅ **Expected Output (if Flannel is configured):**
```json
{
  "Network": "10.42.0.0/16",
  "Backend": {
    "Type": "vxlan"
  }
}
```

---

### **🛠 Next Steps**
1. **Check Flannel status:** Run `sudo journalctl -u k3s | grep 'CNI'`
2. **Confirm active network interfaces:** Run `ip a`
3. **Verify Pod-to-Pod connectivity:** Try creating two Pods and `ping` them.

Let me know what you find! 🚀

---

There's no output from `sudo journalctl -u k3s | grep 'CNI'`, which means K3s **is not explicitly logging a CNI plugin**.  
Let's dig deeper and confirm **what K3s is using for networking**.

---

### **1️⃣ Check if Flannel is Embedded in K3s**
Since K3s **bundles Flannel internally**, try checking if the `flannel` binary is present:  
```sh
sudo ls /var/lib/rancher/k3s/agent/etc/flannel/
```
✅ **Expected Output (if Flannel is present):**  
```
net-conf.json
subnet.env
```
If these files exist, K3s **is using Flannel**, just not as a separate pod.

---

### **2️⃣ Check if Flannel Interfaces Exist**
```sh
ip a | grep -E 'flannel|cni0'
```
✅ **Expected Output (if Flannel is working):**  
```
cni0: <BROADCAST,MULTICAST,UP> mtu 1500
flannel.1: <BROADCAST,MULTICAST,UP> mtu 8950
```
If neither `cni0` nor `flannel.1` exists, Flannel **isn't running**.

---

### **3️⃣ Check K3s Configuration for Networking**
Run:
```sh
sudo cat /etc/rancher/k3s/k3s.yaml | grep cluster-cidr
```
✅ **Expected Output (if Flannel is used):**  
```
cluster-cidr: 10.42.0.0/16
```
This confirms **Flannel’s Pod network range**.

---

### **4️⃣ Check Kubernetes Node Configuration**
```sh
kubectl describe node $(hostname)
```
Look for **PodCIDR**:
```
PodCIDR: 10.42.0.0/24
```
- If PodCIDR is **missing**, K3s **might not be using a CNI** or may need a restart.

---

### **5️⃣ Check If K3s Started Without a CNI**
K3s supports running **without a CNI**.  
Run:
```sh
ps aux | grep k3s
```
Look for a flag like `--flannel-backend=none`.  
- If found, Flannel **is disabled**, and you’ll need to install another CNI manually.

---

### **📌 What to Do Next?**
1. **Check if `flannel.1` and `cni0` exist** using `ip a`.
2. **Confirm PodCIDR** using `kubectl describe node $(hostname)`.
3. **See if Flannel config files exist** under `/var/lib/rancher/k3s/agent/etc/flannel/`.

Let me know what you find, and we can troubleshoot further! 🚀

---

Your system has `net-conf.json`, which means **Flannel is present** in K3s but may not be running correctly.  

Let’s dig deeper and confirm its configuration and status.

---

### **1️⃣ Inspect Flannel Configuration**  
Run:  
```sh
sudo cat /var/lib/rancher/k3s/agent/etc/flannel/net-conf.json
```
✅ **Expected Output (if Flannel is configured properly):**
```json
{
  "Network": "10.42.0.0/16",
  "Backend": {
    "Type": "vxlan"
  }
}
```
- **`10.42.0.0/16`** → Default Pod network range in K3s  
- **`vxlan`** → Flannel uses VXLAN encapsulation for inter-node communication  
- If this file is missing or misconfigured, networking may be broken.

---

### **2️⃣ Check If Flannel Interface Exists**
Run:  
```sh
ip a | grep flannel
```
✅ **Expected Output (if Flannel is working):**
```
flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8950
    inet 10.42.0.1/32 scope global flannel.1
```
- If **no `flannel.1` interface exists**, Flannel might not be running.

---

### **3️⃣ Check If CNI Interface (`cni0`) Exists**
Run:  
```sh
ip a | grep cni0
```
✅ **Expected Output (if Flannel is managing Pod networking):**
```
cni0: <BROADCAST,MULTICAST,UP> mtu 1500
    inet 10.42.0.1/24 scope global cni0
```
- If **no `cni0` exists**, K3s might not be applying Flannel correctly.

---

### **4️⃣ Verify Pod Networking**
Run:  
```sh
kubectl get pods -A -o wide
```
- Check **Pod IPs** (should be in `10.42.x.x` range).  
- If Pods **don’t have IPs**, CNI might not be working.  

---

### **5️⃣ Restart K3s to Ensure Flannel Is Loaded**
```sh
sudo systemctl restart k3s
sleep 5
sudo journalctl -u k3s --no-pager | grep flannel
```
- Look for logs mentioning **Flannel initialization**.  
- If nothing appears, Flannel **is not loading properly**.

---

### **📌 Next Steps**
1. **Confirm Flannel network settings:** `cat /var/lib/rancher/k3s/agent/etc/flannel/net-conf.json`
2. **Check if `flannel.1` and `cni0` exist:** `ip a`
3. **Verify if Pods have valid IPs:** `kubectl get pods -A -o wide`
4. **Restart K3s and check logs**: `sudo systemctl restart k3s && sudo journalctl -u k3s --no-pager | grep flannel`

Let me know what you find, and we’ll debug further! 🚀

---

```sh
$ sudo ls /var/lib/rancher/k3s/agent/etc/flannel/
net-conf.json
$ sudo cat /var/lib/rancher/k3s/agent/etc/flannel/net-conf.json
{
	"Network": "10.42.0.0/16",
	"EnableIPv6": false,
	"EnableIPv4": true,
	"IPv6Network": "::/0",
	"Backend": {
	"Type": "vxlan"
}
}
$ ip a | grep flannel
17: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default 
    inet 10.42.0.0/32 scope global flannel.1
$ ip a | grep cni0
18: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default qlen 1000
    inet 10.42.0.1/24 brd 10.42.0.255 scope global cni0
19: veth27226340@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master cni0 state UP group default qlen 1000
20: veth233716f7@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master cni0 state UP group default qlen 1000
21: veth86590575@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master cni0 state UP group default qlen 1000
$ kubectl get pods -A -o wide
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE     IP          NODE      NOMINATED NODE   READINESS GATES
kube-system   coredns-ccb96694c-47s7w                   1/1     Running   0          6m51s   10.42.0.4   vagrant   <none>           <none>
kube-system   local-path-provisioner-5b5f758bcf-sdmws   1/1     Running   0          6m51s   10.42.0.3   vagrant   <none>           <none>
kube-system   metrics-server-7bf7d58749-h8m5f           1/1     Running   0          6m51s   10.42.0.2   vagrant   <none>           <none>
$ sudo journalctl -u k3s | grep 'CNI'
$
```

### **Observations from Your Outputs**  

✅ **Flannel is Installed and Running**  
- The config file exists at `/var/lib/rancher/k3s/agent/etc/flannel/net-conf.json`  
- `"Type": "vxlan"` confirms Flannel is using **VXLAN encapsulation** for networking.  
- The `flannel.1` interface is **active** (`state UNKNOWN`, which is normal for Flannel).  

✅ **Pod Networking is Functional**  
- The `cni0` bridge is up (`state UP`).  
- Multiple `veth*` interfaces exist, meaning Pods are connected to `cni0`.  
- All Pods have IPs in the `10.42.0.x` subnet (which matches Flannel’s CIDR).  

✅ **K3s is Using Flannel as CNI, but Not Logging It**  
- `sudo journalctl -u k3s | grep 'CNI'` returns nothing.  
- This is **expected in K3s** because Flannel is embedded (it doesn't run as a separate pod).  

---

### **🔍 Understanding What’s Happening**  

📌 **Flannel Setup in K3s**  
1. K3s assigns **`10.42.0.0/16`** as the cluster-wide Pod network (from `net-conf.json`).  
2. The `flannel.1` interface acts as the **overlay network** for inter-node communication.  
3. The `cni0` bridge is where **local Pods connect**.  
4. Each Pod gets a `veth*` interface linked to `cni0`.  
5. Flannel **routes traffic between Pods across nodes** using VXLAN tunnels.  

📌 **Why You Don’t See Flannel in Logs?**  
- K3s **integrates Flannel directly**, so it doesn't start a separate process that would show in logs.  
- Instead, K3s **directly configures Flannel** via `/var/lib/rancher/k3s/agent/etc/flannel/net-conf.json`.  

📌 **How is Pod-to-Pod Communication Working?**  
- Pods on **the same node** communicate via **`cni0` bridge** (Layer 2).  
- Pods on **different nodes** use **VXLAN encapsulation via `flannel.1`**.  

---

### **🛠 Next Steps: Test Pod-to-Pod Networking**  

Let’s **verify if Pods can talk to each other**!  

✅ **Step 1: Deploy Two Test Pods**  
Run:  
```sh
kubectl run pod1 --image=busybox --restart=Never -- sh -c "sleep 3600"
kubectl run pod2 --image=busybox --restart=Never -- sh -c "sleep 3600"
```
Now check their IPs:  
```sh
kubectl get pods -o wide
```
Expected output:
```sh
NAME   READY   STATUS    IP
pod1   1/1     Running   10.42.0.10
pod2   1/1     Running   10.42.0.11
```

✅ **Step 2: Test Connectivity Between Pods**  
Exec into `pod1` and ping `pod2`:  
```sh
kubectl exec -it pod1 -- ping -c 4 10.42.0.11
```
- If this **works**, Pod-to-Pod networking is good.  
- If this **fails**, we’ll debug further.  
