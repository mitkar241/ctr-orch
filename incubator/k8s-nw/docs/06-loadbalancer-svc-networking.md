## **6. LoadBalancer Service (Local K3s Setup)**

### **Steps to Create a LoadBalancer Service (`klipper-lb`)**  
1. **Expose `nginx` as a LoadBalancer Service**  
   ```sh
   kubectl expose pod nginx --type=LoadBalancer --port=80 --target-port=80 --name=nginx-loadbalancer
   ```


3. **Check if the `svclb` Pod is Running**  
```sh
vagrant@vagrant:~$ kubectl get pods -n kube-system | grep svclb
svclb-nginx-loadbalancer-075389d9-v9cf5   1/1     Running   0          39s
vagrant@vagrant:~$ 
```

4. **Test Access from a Node**

Run the following command to check the external IP (which will be your node IP) and assigned port: 

Use `kubectl get svc nginx-loadbalancer` to find the allocated port.
```sh
vagrant@vagrant:~$ kubectl get svc nginx-loadbalancer
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
nginx-loadbalancer   LoadBalancer   10.43.188.172   192.168.0.108   80:30080/TCP   34s
vagrant@vagrant:~$ 
```

- **EXTERNAL-IP:** This is your node IP (`192.168.1.100` in this example).  
- **PORT(S):** The mapped port (`80:30090/TCP` means port `30090` is exposed on the node).  

```sh
curl 192.168.0.108:30080
curl 192.168.0.108
curl vagrant
curl vagrant:30080
curl http://vagrant
curl http://192.168.0.108
```

```sh
vagrant@vagrant:~$ curl 192.168.0.108:30080
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

Since Klipper LB uses the node’s IP, this should return the `nginx` default welcome page.

Once the service has an external IP assigned (which will be your node IP due to `klipper-lb`), it should be accessible.

---

### **Verifying LoadBalancer Functionality in K3s (`klipper-lb`)**  


#### **Step 3: Verify Service Routing in `iptables` (Optional)**
Check how traffic is routed using:  
```sh
vagrant@vagrant:~$ sudo iptables -t nat -L -n -v | grep nginx-loadbalancer
    4   240 KUBE-MARK-MASQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* masquerade traffic for default/nginx-loadbalancer external destinations */
    1    60 KUBE-EXT-2YKFRC5JDWUQ7NLU  tcp  --  *      *       0.0.0.0/0            127.0.0.0/8          /* default/nginx-loadbalancer */ tcp dpt:30080 nfacct-name  localhost_nps_accepted_pkts
    1    60 KUBE-EXT-2YKFRC5JDWUQ7NLU  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx-loadbalancer */ tcp dpt:30080
    0     0 KUBE-MARK-MASQ  all  --  *      *       10.42.0.10           0.0.0.0/0            /* default/nginx-loadbalancer */
    6   360 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx-loadbalancer */ tcp to:10.42.0.10:80
    2   120 KUBE-SVC-2YKFRC5JDWUQ7NLU  tcp  --  *      *       0.0.0.0/0            10.43.188.172        /* default/nginx-loadbalancer cluster IP */ tcp dpt:80
    2   120 KUBE-EXT-2YKFRC5JDWUQ7NLU  tcp  --  *      *       0.0.0.0/0            192.168.0.108        /* default/nginx-loadbalancer loadbalancer IP */ tcp dpt:80
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !10.42.0.0/16         10.43.188.172        /* default/nginx-loadbalancer cluster IP */ tcp dpt:80
    6   360 KUBE-SEP-KGZWVJQGNVP5OXWQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx-loadbalancer -> 10.42.0.10:80 */
vagrant@vagrant:~$ 
```
