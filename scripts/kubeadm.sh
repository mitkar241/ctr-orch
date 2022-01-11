#!/bin/bash

<<DESC
@ FileName   : kubeadm.sh
@ Description: Installation of multi-node kubeadm
@ Usage      : chmod +x kubeadm.sh
  - master:
    - sudo ./kubeadm.sh --kind=master --hostname=kmaster
  - worker:
    - sudo ./kubeadm.sh --kind=worker --hostname=kworker1
    - final step:
      - copy cluster token from master node
      - sudo kubeadm join <host-ip>:6443 --token xyz321.abc123 --discovery-token-ca-cert-hash sha256:xxx
DESC

# usage function
function usage() {
  cat << EOF
Usage: $ master.sh [-<a>|--<arg> <value>]

required arguments:
  -k|--kind=[master|worker]     provide node kind

optional arguments:
  -h, --help                    provides usage of script
  -H, --hostname=HOSTNAME       provide hostname
  -d, --docker-version=VERSION  pass in a number
  -k, --k8s-version=VERSION     pass in a time string
  -v, --verbose                 increase the verbosity of the bash script
  --dry-run                     do a dry run, dont change any files
EOF
}

# function used to parse CLI arguments
function argparse {
  local kind=
  local hostname=
  local docker_version=
  local k8s_version=
  for i in "$@"; do
    case $i in
      -h|--help)
        usage;
        exit 1;
        ;;
      -k=*|--kind=*)
        kind="${i#*=}"
        if [[ $kind -ne "master" ]] && [[ $kind -ne "worker" ]]; then
          echo "required arguments: -k|--kind=[master|worker]"
        fi
        shift;
        ;;
      -H=*|--hostname=*)
        hostname="${i#*=}"
        shift;
        ;;
      -d=*|--docker-version=*)
        docker_version="${i#*=}"
        shift;
        ;;
      -k=*|--k8s-version=*)
        k8s_version="${i#*=}"
        shift;
        ;;
      -*|--*)
        echo "Unknown Option : $i"
        exit 1;
        ;;
      *)
        ;;
    esac
  done
  echo "$kind:$hostname:$docker_version:$k8s_version"
}

# set hostname
function setHostname() {
  hostname=$1
  hostnamectl set-hostname $hostname
}

# for testing
function disableFirewall() {
  ufw disable
}

# off swap
function disableSwap() {
  swapoff -a; sed -i '/swap/d' /etc/fstab
}

# Update sysctl settings for Kubernetes networking
function updateSysctl() {
  cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
  sysctl --system
}

# Install docker engine
function installDocker() {
  local version=$1
  if [[ -n "$version" ]]; then
    version="="$version
  fi
  apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update
  apt install -y docker-ce$version containerd.io
  groupadd docker
  usermod -aG docker $USER
}

# Install Kubernetes components
function installK8s() {
  local version=$1
  if [[ -n "$version" ]]; then
    version="="$version
  fi
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
  apt update && apt install -y kubeadm$version kubelet$version kubectl$version
}

# Initialize Kubernetes Cluster
function initK8sCluster() {
  mgmtip=$(hostname -I | cut -d' ' -f1-1)
  kubeadm init --apiserver-advertise-address=$mgmtip --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors=all
}

# Deploy Calico network
function deployCalico() {
  kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
}

# To be able to run kubectl commands as non-root user
# NOTE: not functioning well as non-sudo
function nonSudoCompatiability() {
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

# Cluster join command
# NOTE: Note the Output Command
function getClusterToken() {
  kubeadm token create --print-join-command
}

function main() {
  # cli argument storage
  local script=$0
  local args=$@
  local arglist=
  # argument variables
  local kind
  local hostname
  local docker_version
  local k8s_version
  
  # parse CLI arguments
  arglist=$(argparse $args)
  IFS=":"
  read kind hostname docker_version k8s_version<<<$arglist
  IFS=$' \t\n'
  #validateVersion
  
  setHostname ${hostname}
  disableFirewall
  updateSysctl
  installDocker ${docker_version}
  installK8s ${k8s_version}

  if [[ $kind == "master" ]]; then
    initK8sCluster
    deployCalico
    nonSudoCompatiability
    getClusterToken
  fi
}

main "$@"
