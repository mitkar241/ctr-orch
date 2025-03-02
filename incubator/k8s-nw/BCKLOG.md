# Backlog - Kubernetes Networking Learning Plan
---

## **9. Pod-to-Pod Communication Across Namespaces**

- **Description:** Learn how Pods in different namespaces communicate.  
- **Topics Covered:**  
  - Kubernetes **DNS resolution across namespaces** (`nginx.default.svc.cluster.local`).  
  - Using `kubectl exec` to test cross-namespace networking.  
  - Restricting communication using **NetworkPolicies**.  
- **Practical Steps:**  
  - Create two namespaces (`frontend` and `backend`).  
  - Deploy an app in each namespace.  
  - Test connectivity with `kubectl exec`.  
  - Block communication using a **NetworkPolicy**.  

### **9.1 Test Cross-Namespace Connectivity**
- **Description:** Verify if a Pod in one namespace can reach a Pod in another namespace.
- **Reference Material:**
  - `kubectl exec -it busybox -- wget -O- http://nginx.backend.svc.cluster.local`
- **Definition of Done:**
  - Successfully access `nginx` running in the `backend` namespace from a Pod in the `frontend` namespace.

### **9.2 Restrict Cross-Namespace Communication**
- **Description:** Apply a **NetworkPolicy** to block traffic between namespaces.
- **Reference Material:**
  - Create a NetworkPolicy YAML restricting ingress from other namespaces.
  - Apply with `kubectl apply -f network-policy.yaml`.
- **Definition of Done:**
  - Traffic from `frontend` namespace is blocked when accessing `nginx` in `backend` namespace.

---

## **16. Multi-Interface Pods (Multus CNI)**

- **Description:** Assign **multiple network interfaces** to a single Pod.  
- **Topics Covered:**  
  - Installing **Multus CNI** for multi-interface Pods.  
  - Configuring **SR-IOV for high-performance networking**.  
  - Running **dual-homed Pods** with public & private interfaces.  
- **Practical Steps:**  
  - Deploy a Pod with two interfaces (`eth0` and `eth1`).  
  - Verify IP assignment with `ip addr`.  
  - Route specific traffic via `eth1` using `ip rule add`.  

### **16.1 Install Multus CNI**
- **Description:** Enable multiple network interfaces for a Pod.
- **Reference Material:**
  - Deploy Multus using `kubectl apply -f multus-daemonset.yml`
- **Definition of Done:**
  - Pods can have multiple interfaces.

### **16.2 Assign Secondary Network Interface**
- **Description:** Configure a Pod with two interfaces (`eth0` and `eth1`).
- **Reference Material:**
  - Define a NetworkAttachmentDefinition in a Pod spec.
- **Definition of Done:**
  - Pod can communicate via both interfaces.

---

## **1️⃣4️⃣ Advanced Traffic Routing with Ingress Controllers**
- **Description:** Use Nginx, Traefik, or HAProxy for advanced traffic control.  
- **Topics Covered:**  
  - Path-based routing (`/api` → backend1, `/web` → backend2).  
  - Weighted routing (50% traffic to v1, 50% to v2).  
  - WebSocket and gRPC support over Ingress.  
- **Practical Steps:**  
  - Create an Nginx Ingress rule with weighted traffic:  
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: weighted-ingress
    spec:
      rules:
      - host: example.local
        http:
          paths:
          - path: /
            backend:
              service:
                name: backend-v1
                port:
                  number: 80
            weight: 50
          - path: /
            backend:
              service:
                name: backend-v2
                port:
                  number: 80
            weight: 50
    ```

---

## **10. Kubernetes Network Performance Optimization**

- **Description:** Optimize networking performance inside a cluster.  
- **Topics Covered:**  
  - Reducing **packet drops** with optimized CNI settings.  
  - Configuring **TCP Keep-Alive** and **timeouts**.  
  - Using **Node Local DNS Cache** (`nodelocaldns.kube-system`).  
- **Practical Steps:**  
  - Tune MTU for overlay networks (`ip link set mtu 1450 dev flannel.1`).  
  - Enable **CoreDNS caching** for faster DNS lookups.  
  - Test performance using `iperf3` inside Pods.  

### **10.1 Optimize MTU for Overlay Networks**
- **Description:** Adjust MTU settings to reduce fragmentation.
- **Reference Material:**
  - `ip link set mtu 1450 dev flannel.1`
  - `kubectl get nodes -o wide`
- **Definition of Done:**
  - Reduced packet fragmentation in overlay networks.

### **10.2 Enable CoreDNS Caching**
- **Description:** Improve DNS lookup speeds by enabling local CoreDNS caching.
- **Reference Material:**
  - `kubectl edit configmap coredns -n kube-system`
- **Definition of Done:**
  - Faster DNS resolutions inside Pods.

---

## **11. Kubernetes Service Discovery Beyond Cluster**

- **Description:** Expose internal Kubernetes services to **external VMs** or **bare-metal servers**.  
- **Topics Covered:**  
  - Using `kube-proxy` to route traffic to a Kubernetes Service.  
  - Configuring External DNS with `external-dns` Helm chart.  
  - Integrating Kubernetes with Consul or CoreDNS for external service discovery.  
- **Practical Steps:**  
  - Deploy `external-dns` and test external resolution.  
  - Configure **Consul Connect** to bridge Kubernetes and external VMs.  

### **11.1 Access Kubernetes Services from External VM**
- **Description:** Expose a ClusterIP service externally for non-cluster clients.
- **Reference Material:**
  - `kubectl port-forward svc/nginx-service 8080:80`
  - `curl http://<external-vm-ip>:8080`
- **Definition of Done:**
  - External VM can access `nginx` service via port-forwarding.

### **11.2 Use External DNS for Kubernetes Services**
- **Description:** Configure `external-dns` to manage external DNS records dynamically.
- **Reference Material:**
  - `helm install external-dns bitnami/external-dns`
- **Definition of Done:**
  - Kubernetes services are discoverable using external DNS.

---

## **12. Using MetalLB for Bare-Metal LoadBalancers**

- **Description:** Implement `LoadBalancer` type Services **without cloud providers**.  
- **Topics Covered:**  
  - Installing **MetalLB** on bare-metal Kubernetes.  
  - Assigning static IPs to LoadBalancer Services.  
  - Configuring **BGP (Border Gateway Protocol)** for advanced routing.  
- **Practical Steps:**  
  - Install MetalLB and create an address pool.  
  - Deploy a LoadBalancer service and test external access.  

### **12.1 Install and Configure MetalLB**
- **Description:** Deploy MetalLB as a LoadBalancer solution for on-prem Kubernetes.
- **Reference Material:**
  - `kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml`
- **Definition of Done:**
  - LoadBalancer IP is assigned to services.

### **12.2 Expose Service with MetalLB**
- **Description:** Assign a LoadBalancer IP from the MetalLB pool to a service.
- **Reference Material:**
  - `kubectl expose deployment nginx --type=LoadBalancer --port=80`
- **Definition of Done:**
  - Service is externally reachable using MetalLB-assigned IP.

---

## **13. Kubernetes IPv4/IPv6 Dual-Stack Load Balancing**

- **Description:** Enable and configure **dual-stack networking** for Pods and Services.  
- **Topics Covered:**  
  - Assigning **both IPv4 and IPv6 addresses** to Pods.  
  - Exposing IPv6 Services with MetalLB.  
  - Debugging IPv6 traffic with `tcpdump -i eth0 ip6`.  
- **Practical Steps:**  
  - Enable `dualStack` in `kubelet` and `kube-proxy`.  
  - Deploy a Pod and verify it has both IPv4 and IPv6 addresses.  

### **13.1 Enable Dual-Stack Networking**
- **Description:** Configure Kubernetes to assign both IPv4 and IPv6 addresses to Pods.
- **Reference Material:**
  - Modify kubelet and kube-proxy settings for dual-stack.
- **Definition of Done:**
  - Pods have both IPv4 and IPv6 addresses.

### **13.2 Expose Service over IPv6**
- **Description:** Configure MetalLB to support IPv6.
- **Reference Material:**
  - `kubectl get svc nginx -o jsonpath='{.spec.clusterIPs}'`
- **Definition of Done:**
  - The service has an IPv6 address assigned and accessible.

---

## **14. Traffic Splitting & Canary Deployments with Service Mesh**

- **Description:** Implement **progressive deployments** with Istio/Linkerd.  
- **Topics Covered:**  
  - **Traffic splitting** (e.g., 90% to v1, 10% to v2).  
  - **Canary deployments** using a Service Mesh.  
  - **A/B testing** and gradual rollout strategies.  
- **Practical Steps:**  
  - Install Istio and create **VirtualService** rules.  
  - Deploy `nginx:v1` and `nginx:v2` with **weighted traffic**.  

### **14.1 Install Istio and Configure Traffic Routing**
- **Description:** Deploy Istio to split traffic between service versions.
- **Reference Material:**
  - `istioctl install --set profile=demo`
- **Definition of Done:**
  - Istio VirtualService routes 90% traffic to `v1` and 10% to `v2`.

### **14.2 Validate Canary Deployment**
- **Description:** Test if traffic is split correctly between versions.
- **Reference Material:**
  - `curl http://my-service`
- **Definition of Done:**
  - Traffic is distributed as per defined weights.

---

## **15. Multi-Tenancy Networking in Kubernetes**

- **Description:** Isolate network traffic for different teams or environments.  
- **Topics Covered:**  
  - Using **Kubernetes NetworkPolicies** for tenant isolation.  
  - Implementing **VPC-like isolation** with Cilium/Calico.  
  - Creating dedicated **Ingress rules per tenant**.  
- **Practical Steps:**  
  - Deploy two apps in separate namespaces.  
  - Block traffic between them using **NetworkPolicy**.  
  - Configure **Ingress** to route traffic per tenant domain.  

### **15.1 Enforce Namespace Isolation**
- **Description:** Use NetworkPolicies to isolate tenant traffic.
- **Reference Material:**
  - Apply NetworkPolicy to allow only namespace-internal communication.
- **Definition of Done:**
  - Pods from different tenants cannot communicate.

### **15.2 Create Per-Tenant Ingress Rules**
- **Description:** Route traffic based on tenant-specific domains.
- **Reference Material:**
  - Define separate Ingress rules for `tenant1.example.com` and `tenant2.example.com`.
- **Definition of Done:**
  - Requests are routed correctly based on domain.

---

## **17. Dynamic DNS Updates for Kubernetes Services**

- **Description:** Use **CoreDNS and ExternalDNS** for **dynamic hostname assignment**.  
- **Topics Covered:**  
  - Configuring **CoreDNS custom zones** for internal DNS.  
  - Using **ExternalDNS** to register Kubernetes Services in Route 53/DNS servers.  
  - Implementing **internal load balancing via DNS**.  
- **Practical Steps:**  
  - Create a **CoreDNS custom config** for `*.cluster.local`.  
  - Deploy ExternalDNS to register Kubernetes Service IPs dynamically.  

### **17.1 Configure CoreDNS for Custom Zones**
- **Description:** Add a custom DNS zone to CoreDNS for internal services.
- **Reference Material:**
  - Edit `ConfigMap` in `kube-system` namespace.
- **Definition of Done:**
  - Internal services resolve with custom DNS names.

### **17.2 Deploy ExternalDNS**
- **Description:** Automate external DNS updates for Kubernetes services.
- **Reference Material:**
  - Deploy ExternalDNS with Helm.
- **Definition of Done:**
  - Kubernetes Services are registered in external DNS.

---

## **18. Kubernetes Network Traffic Monitoring & Observability**

- **Description:** Monitor real-time network traffic in Kubernetes.  
- **Topics Covered:**  
  - Using **Cilium Hubble** for flow visualization.  
  - Inspecting DNS requests with `kubectl logs -n kube-system coredns`.  
  - Using **Grafana + Prometheus** for network analytics.  
- **Practical Steps:**  
  - Deploy **Cilium Hubble** and view real-time traffic.  
  - Set up **Grafana dashboards** for network metrics.  

### **18.1 Install Cilium Hubble**
- **Description:** Deploy Cilium Hubble to monitor real-time network flows.
- **Reference Material:**
  - Install with `helm install cilium cilium/cilium --set hubble.enabled=true`
- **Definition of Done:**
  - Live traffic visibility in Hubble UI.

### **18.2 Enable Network Metrics in Prometheus**
- **Description:** Use Prometheus to track network request latency.
- **Reference Material:**
  - Deploy Prometheus with network exporter.
- **Definition of Done:**
  - Network latency metrics available in Grafana.

---

### **19.1 Enable IPv6 in Kubernetes**
- **Description:** Configure Kubernetes to support dual-stack networking with both IPv4 and IPv6.
- **Reference Material:**
  - [Kubernetes Dual-Stack Networking](https://kubernetes.io/docs/concepts/services-networking/dual-stack/)
- **Definition of Done:**
  - Kubernetes cluster supports IPv6 and can route traffic over both IPv4 and IPv6.

### **19.2 Test IPv6 Connectivity**
- **Description:** Verify Pod-to-Pod and Service communication over IPv6.
- **Reference Material:**
  - `kubectl exec -it busybox -- ping6 <ipv6-pod-ip>`
- **Definition of Done:**
  - Successfully send and receive traffic over IPv6.

---

### **20.1 Configure Network Policy for Egress Traffic**
- **Description:** Implement a NetworkPolicy to control egress traffic from Pods.
- **Reference Material:**
  - [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- **Definition of Done:**
  - Egress traffic is restricted based on defined rules.

### **20.2 Verify Egress Policy Enforcement**
- **Description:** Test egress control using `kubectl exec`.
- **Reference Material:**
  - `kubectl exec -it busybox -- curl http://external-service`
- **Definition of Done:**
  - Traffic is allowed/denied as per policy rules.

---

### **21.1 Implement Pod Security and Network Segmentation**
- **Description:** Use `NetworkPolicy` to isolate namespaces and restrict Pod communication.
- **Reference Material:**
  - [Namespace Isolation](https://kubernetes.io/docs/concepts/security/pod-security-policy/)
- **Definition of Done:**
  - Pods in one namespace cannot access Pods in another without explicit policies.

### **21.2 Validate Network Segmentation**
- **Description:** Use `kubectl exec` to verify network restrictions.
- **Reference Material:**
  - `kubectl exec -it busybox -- wget -O- http://nginx.namespace2`
- **Definition of Done:**
  - Restricted cross-namespace traffic as per policy.

---

### **22.1 Deploy a CNI Plugin for Advanced Networking**
- **Description:** Install a CNI (e.g., Calico, Cilium, Flannel) for enhanced networking features.
- **Reference Material:**
  - [Calico Installation Guide](https://docs.projectcalico.org/getting-started/kubernetes/)
- **Definition of Done:**
  - CNI plugin is deployed and active.

### **22.2 Validate CNI Functionality**
- **Description:** Test connectivity and policies provided by the CNI.
- **Reference Material:**
  - `kubectl get pods -n kube-system | grep calico`
- **Definition of Done:**
  - CNI policies function as expected.

---

### **23.1 Implement Multi-Cluster Networking**
- **Description:** Set up communication between Kubernetes clusters.
- **Reference Material:**
  - [Kubernetes Multi-Cluster](https://kubernetes.io/docs/concepts/cluster-administration/federation/)
- **Definition of Done:**
  - Pods in different clusters can communicate securely.

### **23.2 Test Multi-Cluster Pod Communication**
- **Description:** Deploy services in different clusters and test connectivity.
- **Reference Material:**
  - `kubectl exec -it busybox -- curl http://service.other-cluster`
- **Definition of Done:**
  - Successful multi-cluster networking.

---

### **24.1 Set Up Service Mesh for Traffic Management**
- **Description:** Deploy Istio or Linkerd for advanced networking features like traffic routing and security.
- **Reference Material:**
  - [Istio Installation](https://istio.io/latest/docs/setup/install/)
- **Definition of Done:**
  - Service mesh is deployed and traffic can be managed.

### **24.2 Configure Traffic Routing in Service Mesh**
- **Description:** Define traffic rules for intelligent routing within the mesh.
- **Reference Material:**
  - `kubectl apply -f virtualservice.yaml`
- **Definition of Done:**
  - Requests follow defined routing rules.

---

### **25.1 Monitor and Debug Network Traffic**
- **Description:** Use monitoring tools (e.g., Prometheus, Grafana) to observe network traffic.
- **Reference Material:**
  - [Kubernetes Monitoring](https://prometheus.io/docs/prometheus/latest/getting_started/)
- **Definition of Done:**
  - Live traffic metrics are visible.

### **25.2 Capture and Analyze Network Packets**
- **Description:** Use `tcpdump` or `Wireshark` to capture and inspect Kubernetes network traffic.
- **Reference Material:**
  - `kubectl exec -it busybox -- tcpdump -i eth0 -w capture.pcap`
- **Definition of Done:**
  - Packet capture provides insights into traffic flows.

---

## **9️⃣ Kubernetes Network Routing & Traffic Control**  
- **Description:** Understand how traffic is routed inside Kubernetes.  
- **Topics Covered:**  
  - Pod-to-Pod communication via CNI (Flannel, Calico, Cilium).  
  - Service-to-Pod routing using `kube-proxy`.  
  - LoadBalancer-to-Node traffic flow.  
  - Debugging routes with `ip route`.  
- **Practical Steps:**  
  - Use `kubectl get endpoints` to see where traffic is sent.  
  - Run `kubectl exec -it busybox -- ip route show`.  
  - Inspect Flannel or Calico interfaces (`ip addr show flannel.1`).  

---

## **🔟 Multi-Cluster Networking (Service Mesh)**
- **Description:** Enable communication across multiple Kubernetes clusters.  
- **Topics Covered:**  
  - Using **Istio, Linkerd, or Cilium** for service-to-service communication.  
  - Multi-cluster networking with **Submariner**.  
  - Global service discovery (exposing services across clusters).  
- **Practical Steps:**  
  - Deploy **Istio Gateway** for cross-cluster communication.  
  - Configure Submariner for inter-cluster routing.  

---

## **1️⃣1️⃣ Kubernetes Egress & Ingress Traffic Management**
- **Description:** Control traffic leaving and entering the cluster.  
- **Topics Covered:**  
  - Kubernetes **Egress rules** (restricting outbound traffic).  
  - Kubernetes **Ingress policies** (controlling incoming traffic).  
  - Using **ExternalDNS** to manage domain mappings.  
- **Practical Steps:**  
  - Create an **Egress NetworkPolicy** to allow only specific traffic:  
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-external-access
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: nginx
      egress:
      - to:
        - ipBlock:
            cidr: 8.8.8.8/32
        ports:
        - protocol: TCP
          port: 53
      policyTypes:
      - Egress
    ```
  - Deploy **ExternalDNS** to dynamically assign DNS records.

---

## **1️⃣2️⃣ Kubernetes Network Security Best Practices**
- **Description:** Secure cluster networking against attacks.  
- **Topics Covered:**  
  - Using **NetworkPolicies** for fine-grained access control.  
  - Enforcing **mTLS (Mutual TLS)** between Pods.  
  - Detecting and blocking **rogue traffic** (Cilium Hubble).  
- **Practical Steps:**  
  - Use **Calico** or **Cilium** to create a zero-trust network.  
  - Monitor network flows with `kubectl get networkpolicy -A`.  

---

## **1️⃣3️⃣ IPv6 & Dual-Stack Networking in Kubernetes**
- **Description:** Enable Kubernetes to run with both IPv4 and IPv6.  
- **Topics Covered:**  
  - Configuring IPv6 networking in K3s.  
  - Using Dual-Stack Services (`kubectl get svc -o wide`).  
  - Debugging IPv6 connectivity (`ping6 <pod-ip>`).  
- **Practical Steps:**  
  - Enable IPv6 in `kubeadm-config.yaml`.  
  - Run a Pod with an IPv6 address and test connectivity.  

---

## **1️⃣5️⃣ Custom Kubernetes CNI Plugins & eBPF**
- **Description:** Build and extend Kubernetes networking with **Custom CNI** plugins.  
- **Topics Covered:**  
  - How **Flannel, Calico, Cilium** work internally.  
  - Using **eBPF** for network observability.  
  - Writing custom Kubernetes CNI plugins.  
- **Practical Steps:**  
  - Install Cilium and run `cilium monitor`.  
  - Deploy a custom CNI using `bridge` mode.  
