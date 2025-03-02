### **Capturing Packet Flows in Kubernetes (K3s)**
Since you want to analyze network traffic between pods, services, and CoreDNS, you'll need to capture packets at different points in the Kubernetes networking stack.

---

## **1️⃣ Install `tcpdump` on Nodes**
First, ensure `tcpdump` is installed on both the **Vagrant (Master) Node** and the **Worker Node**.

```sh
sudo apt update && sudo apt install -y tcpdump
```

---

## **2️⃣ Identify Network Interfaces**
Run the following on **both nodes** to check the interfaces:

```sh
ip a
```

You'll see interfaces like:
- `eth0` → For external communication
- `cni0` → Main CNI bridge (Flannel creates this)
- `flannel.1` → VXLAN overlay interface
- `docker0` → Used by Docker (but not needed for Kubernetes)
- `vxlan.calico` (if using Calico instead of Flannel)

#### **Capture Points:**
| Capture Point        | Interface    | Purpose |
|----------------------|-------------|---------|
| Pod-to-Pod traffic (same node) | `cni0` | See direct pod communication |
| Pod-to-Pod traffic (cross-node) | `flannel.1` | Check VXLAN encapsulated traffic |
| DNS Requests to CoreDNS | `cni0` or `flannel.1` | Check if pods can resolve DNS |
| Service (ClusterIP) Traffic | `cni0` | Verify kube-proxy/NAT routing |
| External Traffic (Ingress) | `eth0` | Debug external connectivity |

---

## **3️⃣ Capture Traffic with `tcpdump`**
Run `tcpdump` on different interfaces to see traffic flow.

### **🔹 Capture DNS Traffic (from CoreDNS)**
Run this on **Vagrant (Master) Node** (where CoreDNS is running):
```sh
sudo tcpdump -i cni0 port 53 -nn -vv
```
Try resolving a service from a pod:
```sh
kubectl exec -it busybox-on-worker -- nslookup nginx-worker-svc
```

---

### **🔹 Capture Pod-to-Pod Communication**
On **worker node** (where `busybox-on-worker` is running), run:
```sh
sudo tcpdump -i cni0 host 10.42.0.3 -nn -vv
```
Then, from **`busybox-on-worker`**, ping the CoreDNS pod:
```sh
kubectl exec -it busybox-on-worker -- ping -c4 10.42.0.3
```

---

### **🔹 Capture Cross-Node VXLAN Traffic**
On **both nodes**, check VXLAN traffic (Flannel uses `flannel.1`):
```sh
sudo tcpdump -i flannel.1 -nn -vv
```
Then, test pod-to-pod communication across nodes:
```sh
kubectl exec -it busybox-on-worker -- ping -c4 busybox-on-master
```

---

### **🔹 Capture Service Traffic**
Check traffic to a **ClusterIP service** (`nginx-worker-svc`):
```sh
sudo tcpdump -i cni0 host 10.43.17.237 -nn -vv
```
Then, from the `busybox-on-worker` pod:
```sh
wget -O- nginx-worker-svc
```

---

## **4️⃣ Save & Analyze PCAP Files**
If you want to analyze the packets using **Wireshark**, save the capture:
```sh
sudo tcpdump -i cni0 -w capture.pcap
```
Copy the file to your local machine and open it in **Wireshark**:
```sh
scp vagrant@192.168.0.110:/home/vagrant/capture.pcap .
wireshark capture.pcap
```

---

### **Summary**
- `cni0` → **Pod-to-Pod, Service Traffic**
- `flannel.1` → **VXLAN Encapsulated Traffic**
- `eth0` → **External Traffic (Ingress)**
- Use `tcpdump -i <interface> port <port>` to filter specific traffic.
