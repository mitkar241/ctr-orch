#sudo su -

hostname=$1
mgmtip=$(nslookup $hostname | grep -i "address" | tail -1| cut -d' ' -f2)

ufw disable
#Firewall stopped and disabled on system startup

swapoff -a
cat /etc/fstab | grep "swap" | wc -l
#1
sed -i '/swap/d' /etc/fstab
cat /etc/fstab | grep "swap" | wc -l
#0

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
cat /etc/sysctl.d/kubernetes.conf
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
sysctl --system
sysctl --system | grep -i "/etc/sysctl.d/kubernetes.conf" | wc -l
#sysctl: setting key "net.ipv4.conf.all.promote_secondaries": Invalid argument
#1

apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#OK
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#OK
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
cat /etc/apt/sources.list.d/kubernetes.list | grep "kubernetes-xenial" | wc -l
#1
apt update && apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00

mknod /dev/kmsg c 1 11
echo '#!/bin/sh -e' >> /etc/rc.local
echo 'mknod /dev/kmsg c 1 11' >> /etc/rc.local
chmod +x /etc/rc.local
cat /etc/rc.local
##!/bin/sh -e
#mknod /dev/kmsg c 1 11

kubeadm config images pull
kubeadm init --apiserver-advertise-address=$mgmtip --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors=all

kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

kubeadm token create --print-join-command
#kubeadm join 192.168.0.6:6443 --token xx.xxxx     --discovery-token-ca-cert-hash sha256:abc123
