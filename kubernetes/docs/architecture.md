# Kubernetes Architecture
---
## Table of Contents
---
- [Table of Contents](#table-of-contents)
- [Resources](#resources)
- [What is Kubernetes](#what-is-kubernetes)
- [Kubernetes Architecture Definition](#kubernetes-architecture-definition)
- [What is Kubernetes Architecture](#what-is-kubernetes-architecture)
- [Kubernetes Control Plane](#kubernetes-control-plane)
  * [Kubernetes API Server](#kubernetes-api-server)
  * [Kubernetes Scheduler](#kubernetes-scheduler)
  * [Kubernetes Controller Manager](#kubernetes-controller-manager)
  * [ETCD](#etcd)
  * [Cloud Controller Manager](#cloud-controller-manager)
- [Kubernetes Cluster Architecture](#kubernetes-cluster-architecture)
  * [Kubelet service](#kubelet-service)
  * [Kube-proxy service](#kube-proxy-service)
- [Kubernetes Concepts](#kubernetes-concepts)
  * [Nodes](#nodes)
  * [Container Runtime Engine](#container-runtime-engine)
  * [Pods](#pods)
  * [Service](#service)
  * [Volume](#volume)
  * [Namespace](#namespace)
  * [Deployment](#deployment)
- [Additional Kubernetes Web Application Architecture Components](#additional-kubernetes-web-application-architecture-components)
- [Kubernetes Architecture Best Practices](#kubernetes-architecture-best-practices)
  * [High Availability](#high-availability)
  * [Scalability](#scalability)
  * [Portability](#portability)
  * [Security](#security)
- [Configuring Kubernetes Architecture Security](#configuring-kubernetes-architecture-security)

## Resources
---
- [ ] [Kubernetes Architecture - avinetworks](https://avinetworks.com/glossary/kubernetes-architecture/)
- [ ] [Kubernetes Architecture - aquasec](https://www.aquasec.com/cloud-native-academy/kubernetes-101/kubernetes-architecture/)

## What is Kubernetes
---
Kubernetes is an open source orchestration tool developed by Google for managing microservices or containerized applications across a distributed cluster of nodes. Kubernetes provides highly resilient infrastructure with zero downtime deployment capabilities, automatic rollback, scaling, and self-healing of containers (which consists of auto-placement, auto-restart, auto-replication , and scaling of containers on the basis of CPU usage).

The main objective of Kubernetes is to hide the complexity of managing a fleet of containers by providing REST APIs for the required functionalities. Kubernetes is portable in nature, meaning it can run on various public or private cloud platforms such as AWS, Azure, OpenStack, or Apache Mesos. It can also run on bare metal machines.

`N.B.` Configure the Kubernetes API server securely. Disable anonymous/unauthenticated access and use TLS encryption for connections

## Kubernetes Architecture Definition
---
Kubernetes is an open source container deployment and management platform. It offers container orchestration, a container runtime, container-centric infrastructure orchestration, load balancing, self-healing mechanisms, and service discovery. Kubernetes architecture, also sometimes called Kubernetes application deployment architecture or Kubernetes client server architecture, is used to compose, scale, deploy, and manage application containers across host clusters.

An environment running Kubernetes consists of the following basic components: a control plane (Kubernetes control plane), a distributed key-value storage system for keeping the cluster state consistent (etcd), and cluster nodes (Kubelets, also called worker nodes or minions).

Kubernetes follows a client-server architecture. It’s possible to have a multi-master setup (for high availability), but by default there is a single master server which acts as a controlling node and point of contact. The master server consists of various components including a kube-apiserver, an etcd storage, a kube-controller-manager, a cloud-controller-manager, a kube-scheduler, and a DNS server for Kubernetes services. Node components include kubelet and kube-proxy on top of Docker.

## What is Kubernetes Architecture
---
A Kubernetes cluster is a form of Kubernetes deployment architecture. Basic Kubernetes architecture exists in two parts: the control plane and the nodes or compute machines. Each node could be either a physical or virtual machine and is its own Linux environment. Every node also runs pods, which are composed of containers.

Kubernetes architecture components or K8s components include the Kubernetes control plane and the nodes in the cluster. The control plane machine components include the Kubernetes API server, Kubernetes scheduler, Kubernetes controller manager, and etcd. Kubernetes node components include a container runtime engine or docker, a Kubelet service, and a Kubernetes proxy service.

## Kubernetes Control Plane
---
The control plane is the nerve center that houses Kubernetes cluster architecture components that control the cluster. It also maintains a data record of the configuration and state of all of the cluster’s Kubernetes objects.

The Kubernetes control plane is in constant contact with the compute machines to ensure that the cluster runs as configured. Controllers respond to cluster changes to manage object states and drive the actual, observed state or current status of system objects to match the desired state or specification.

Several major components comprise the control plane: the API server, the scheduler, the controller-manager, and etcd. These core Kubernetes components ensure containers are running with the necessary resources in sufficient numbers. These components can all run on one primary node, but many enterprises concerned about fault tolerance replicate them across multiple nodes to achieve high availability.

### Kubernetes API Server
---
The front end of the Kubernetes control plane, the API Server supports updates, scaling, and other kinds of lifecycle orchestration by providing APIs for various types of applications. Clients must be able to access the API server from outside the cluster, because it serves as the gateway, supporting lifecycle orchestration at each stage. In that role, clients use the API server as a tunnel to pods, services, and nodes, and authenticate via the API server.

Kubernetes API server is the central management entity that receives all REST requests for modifications (to pods, services, replication sets/controllers and others), serving as frontend to the cluster. Also, this is the only component that communicates with the etcd cluster, making sure data is stored in etcd and is in agreement with the service details of the deployed pods.

### Kubernetes Scheduler
---
The Kubernetes scheduler stores the resource usage data for each compute node; determines whether a cluster is healthy; and determines whether new containers should be deployed, and if so, where they should be placed. The scheduler considers the health of the cluster generally alongside the pod’s resource demands, such as CPU or memory. Then it selects an appropriate compute node and schedules the task, pod, or service, taking resource limitations or guarantees, data locality, the quality of the service requirements, anti-affinity and affinity specifications, and other factors into account.

helps schedule the pods (a co-located group of containers inside which our application processes are running) on the various nodes based on resource utilization. It reads the service’s operational requirements and schedules it on the best fit node. For example, if the application needs 1GB of memory and 2 CPU cores, then the pods for that application will be scheduled on a node with at least those resources. The scheduler runs each time there is a need to schedule pods. The scheduler must know the total resources available as well as resources allocated to existing workloads on each node.

### Kubernetes Controller Manager
---
There are various controllers in a Kubernetes ecosystem that drive the states of endpoints (pods and services), tokens and service accounts (namespaces), nodes, and replication (autoscaling). The controller manager—sometimes called cloud controller manager or simply controller—is a daemon which runs the Kubernetes cluster using several controller functions.

The controller watches the objects it manages in the cluster as it runs the Kubernetes core control loops. It observes them for their desired state and current state via the API server. If the current and desired states of the managed objects don’t match, the controller takes corrective steps to drive object status toward the desired state. The Kubernetes controller also performs core lifecycle functions.

runs a number of distinct controller processes in the background (for example, replication controller controls number of replicas in a pod, endpoints controller populates endpoint objects like services and pods, and others) to regulate the shared state of the cluster and perform routine tasks. When a change in a service configuration occurs (for example, replacing the image from which the pods are running, or changing parameters in the configuration yaml file), the controller spots the change and starts working towards the new desired state.

### ETCD
---
Distributed and fault-tolerant, etcd is an open source, key-value store database that stores configuration data and information about the state of the cluster. etcd may be configured externally, although it is often part of the Kubernetes control plane.

etcd stores the cluster state based on the Raft consensus algorithm. This helps cope with a common problem that arises in the context of replicated state machines and involves multiple servers agreeing on values. Raft defines three different roles: leader, candidate, and follower, and achieves consensus by electing a leader.

In this way, etcd acts as the single source of truth (SSOT) for all Kubernetes cluster components, responding to queries from the control plane and retrieving various parameters of the state of the containers, nodes, and pods. etcd is also used to store configuration details such as ConfigMaps, subnets, and Secrets, along with cluster state data.

a simple, distributed key value storage which is used to store the Kubernetes cluster data (such as number of pods, their state, namespace, etc), API objects and service discovery details. It is only accessible from the API server for security reasons. etcd enables notifications to the cluster about configuration changes with the help of watchers. Notifications are API requests on each etcd cluster node to trigger the update of information in the node’s storage.

### Cloud Controller Manager
---
is responsible for managing controller processes with dependencies on the underlying cloud provider (if applicable). For example, when a controller needs to check if a node was terminated or set up routes, load balancers or volumes in the cloud infrastructure, all that is handled by the cloud-controller-manager.

## Kubernetes Cluster Architecture
---
Managed by the control plane, cluster nodes are machines that run containers. Each node runs an agent for communicating with the control plane, the kubelet—the primary Kubernetes controller. Each node also runs a container runtime engine, such as Docker or rkt. The node also runs additional components for monitoring, logging, service discovery, and optional extras.

Here are some Kubernetes cluster components in focus:

### Kubelet service
---
Each compute node includes a kubelet, an agent that communicates with the control plane to ensure the containers in a pod are running. When the control plane requires a specific action happen in a node, the kubelet receives the pod specifications through the API server and executes the action. It then ensures the associated containers are healthy and running.

the main service on a node, regularly taking in new or modified pod specifications (primarily through the kube-apiserver) and ensuring that pods and their containers are healthy and running in the desired state. This component also reports to the master on the health of the host where it is running.

### Kube-proxy service
---
Each compute node contains a network proxy called a kube-proxy that facilitates Kubernetes networking services. The kube-proxy either forwards traffic itself or relies on the packet filtering layer of the operating system to handle network communications both outside and inside the cluster.

The kube-proxy runs on each node to ensure that services are available to external parties and deal with individual host subnetting. It serves as a network proxy and service load balancer on its node, managing the network routing for UDP and TCP packets. In fact, the kube-proxy routes traffic for all service endpoints.

a proxy service that runs on each worker node to deal with individual host subnetting and expose services to the external world. It performs request forwarding to the correct pods/containers across the various isolated networks in a cluster.

## Kubernetes Concepts
---
### Nodes
---
A Kubernetes cluster must have at least one compute node, although it may have many, depending on the need for capacity. Pods orchestrated and scheduled to run on nodes, so more nodes are needed to scale up cluster capacity.

Nodes do the work for a Kubernetes cluster. They connect applications and networking, compute, and storage resources.

Nodes may be cloud-native virtual machines (VMs) or bare metal servers in data centers.

### Container Runtime Engine
---
Each compute node runs and manages container life cycles using a container runtime engine. Kubernetes supports Open Container Initiative-compliant runtimes such as Docker, CRI-O, and rkt.

### Pods
---
Until now, we have covered concepts that are internal and infrastructure-focused. In contrast, pods are central to Kubernetes because they are the key outward facing construct that developers interact with.

A pod represents a single instance of an application, and the simplest unit within the Kubernetes object model. However, pods are central and crucial to Kubernetes. Each pod is composed of a container or tightly coupled containers in a series that logically go together, along with rules that control how the containers run.

Pods have a limited lifespan and eventually die after upgrading or scaling back down. However, although they are ephemeral, pods can run stateful applications by connecting to persistent storage.

Pods are also capable of horizontal autoscaling, meaning they can grow or shrink the number of instances running. They can also perform rolling updates and canary deployments.

Pods run together on nodes, so they share content and storage and can reach other pods via localhost. Containers may span multiple machines, so pods may as well. One node can run multiple pods, each collecting multiple containers.

The pod is the core unit of management in the Kubernetes ecosystem and acts as the logical boundary for containers that share resources and context. Differences in virtualization and containerization are mitigated by the pod grouping mechanism, which enables running multiple dependent processes together.

Achieve scaling in pods at runtime by creating replica sets, which deliver availability by constantly maintaining a predefined set of pods, ensuring that the deployment always runs the desired number. Services can expose a single pod or a replica set to external or internal consumers.

Services associate specific criteria with pods to enable their discovery. Pods and services are associated through key-value pairs called selectors and labels. Any new match between a pod label and selector will be discovered automatically by the service.

generally refers to one or more containers that should be controlled as a single application. A pod encapsulates application containers, storage resources, a unique network ID and other configuration on how to run the containers.

### Service
---
pods are volatile, that is Kubernetes does not guarantee a given physical pod will be kept alive (for instance, the replication controller might kill and start a new set of pods). Instead, a service represents a logical set of pods and acts as a gateway, allowing (client) pods to send requests to the service without needing to keep track of which physical pods actually make up the service.

### Volume
---
similar to a container volume in Docker, but a Kubernetes volume applies to a whole pod and is mounted on all containers in the pod. Kubernetes guarantees data is preserved across container restarts. The volume will be removed only when the pod gets destroyed. Also, a pod can have multiple volumes (possibly of different types) associated.

### Namespace
---
a virtual cluster (a single physical cluster can run multiple virtual ones) intended for environments with many users spread across multiple teams or projects, for isolation of concerns. Resources inside a namespace must be unique and cannot access resources in a different namespace. Also, a namespace can be allocated a resource quota to avoid consuming more than its share of the physical cluster’s overall resources.

### Deployment
---
describes the desired state of a pod or a replica set, in a yaml file. The deployment controller then gradually updates the environment (for example, creating or deleting replicas) until the current state matches the desired state specified in the deployment file. For example, if the yaml file defines 2 replicas for a pod but only one is currently running, an extra one will get created. Note that replicas managed via a deployment should not be manipulated directly, only via new deployments.

## Additional Kubernetes Web Application Architecture Components
---
Kubernetes manages an application’s containers, but it can also manage a cluster’s attached application data. Kubernetes users can request storage resources without knowing underlying storage infrastructure details.

A Kubernetes volume is just a directory that is accessible to a pod, which may hold data. The contents of the volume, how it comes to be, and the medium that backs it are determined by the volume type. Persistent volumes (PVs) are specific to a cluster, are generally provisioned by an administrator, and tie into an existing storage resource. PVs can therefore outlast a specific pod.

Kubernetes relies on container images that it stores in a container registry. It can be a third party registry or one an organization configures.

Namespaces are virtual clusters inside a physical cluster. They are intended to provide virtually separated work environments for multiple users, teams, and prevent teams from hindering each other by limiting what Kubernetes objects they can access.
At the pod level, Kubernetes containers within a pod can reach other ports via localhost and share their IP addresses and network namespaces.

## Kubernetes Architecture Best Practices
---
Kubernetes architecture is premised on availability, scalability, portability, and security. Its design is intended to distribute workloads across available resources more efficiently, optimizing the cost of infrastructure.

### High Availability
---
Most container orchestration engines deliver application availability, but Kubernetes high availability architecture is designed to achieve availability of both applications and infrastructure.

Kubernetes architecture ensures high availability on the application front using replication controllers, replica sets, and pet sets. Users can set the minimum number of running pods at any time. The declarative policy can return the deployment to the desired configuration if a pod or container crashes. Configure stateful workloads for high availability using pet sets.

Kubernetes HA architecture also supports infrastructure availability with a wide range of storage backends, from block storage devices such as Google Compute Engine persistent disk and Amazon Elastic Block Store (EBS), to distributed file systems such as GlusterFS and network file system (NFS), and specialized container storage plugins such as Flocker.

Moreover, each Kubernetes cluster component can be configured for high availability. Health checks and load balancers can further ensure availability for containerized applications.

Kubernetes addresses highly availability both at application and infrastructure level. Replica sets ensure that the desired (minimum) number of replicas of a stateless pod for a given application are running. Stateful sets perform the same role for stateful pods. At the infrastructure level, Kubernetes supports various distributed storage backends like AWS EBS, Azure Disk, Google Persistent Disk, NFS, and more. Adding a reliable, available storage layer to Kubernetes ensures high availability of stateful workloads. Also, each of the master components can be configured for multi-node replication (multi-master) to ensure higher availability.

### Scalability
---
Applications deployed in Kubernetes are microservices, composed of many containers grouped into series as pods. Each container is logically designed to perform a single task.

Kubernetes 1.4 supports cluster auto-scaling, and Kubernetes on Google Cloud also supports auto-scaling. During auto-scaling, Kubernetes and the underlying infrastructure coordinate to add additional nodes to the cluster when no available nodes remain to scale pods across.

Kubernetes provides horizontal scaling of pods on the basis of CPU utilization. The threshold for CPU usage is configurable and Kubernetes will automatically start new pods if the threshold is reached. For example, if the threshold is 70% for CPU but the application is actually growing up to 220%, then eventually 3 more pods will be deployed so that the average CPU utilization is back under 70%. When there are multiple pods for a particular application, Kubernetes provides the load balancing capacity across them. Kubernetes also supports horizontal scaling of stateful pods, including NoSQL and RDBMS databases through Stateful sets. A Stateful set is a similar concept to a Deployment, but ensures storage is persistent and stable, even when a pod is removed.

### Portability
---
Kubernetes is designed to offer choice in cloud platforms, container runtimes, operating systems, processor architectures, and PaaS. For example, you can configure a Kubernetes cluster on various Linux distributions, including CoreOS, Red Hat Linux, CentOS, Fedora, Debian, and Ubuntu. It can be deployed to run locally, in a bare metal environment; and in virtualization environments based on vSphere, KVM, and libvirt. Serverless architecture for Kubernetes can run on cloud platforms such as Azure, AWS, and Google Cloud. It’s also possible to create hybrid cloud capabilities by mixing and matching clusters on-premises and across cloud providers.

Kubernetes portability manifests in terms of operating system choices (a cluster can run on any mainstream Linux distribution), processor architectures (either virtual machines or bare metal), cloud providers (AWS, Azure or Google Cloud Platform), and new container runtimes, besides Docker, can also be added. Through the concept of federation, it can also support workloads across hybrid (private and public cloud) or multi-cloud environments. This also supports availability zone fault tolerance within a single cloud provider.

### Security
---
Kubernetes application architecture is configured securely at multiple levels. For a detailed look at Kubernetes Security, please see our discussion here.

Kubernetes addresses security at multiple levels: cluster, application and network. The API endpoints are secured through transport layer security (TLS). Only authenticated users (either service accounts or regular users) can execute operations on the cluster (via API requests). At the application level, Kubernetes secrets can store sensitive information (such as passwords or tokens) per cluster (a virtual cluster if using namespaces, physical otherwise). Note that secrets are accessible from any pod in the same cluster. Network policies for access to pods can be defined in a deployment. A network policy specifies how pods are allowed to communicate with each other and with other network endpoints.

## Configuring Kubernetes Architecture Security
---
To secure Kubernetes clusters, nodes, and containers, there are several best practices based on DevOps practices and cloud-native principles to follow:

Update Kubernetes to the latest version. Only the latest three versions of Kubernetes are supported with security patches for newly identified vulnerabilities.

Configure the Kubernetes API server securely. Deactivate anonymous/unauthenticated access and use TLS encryption for connections between the API server and kubelets.

Secure etcd. etcd itself is a trusted source, but serves client connections only over TLS.

Secure the kubelet. Deactivate anonymous access to the kubelet. Start the kubelet with the –anonymous-auth=false flag and limit what the kubelet can access with the NodeRestriction admission controller.

Embed security early in the container lifecycle. Ensure shared goals between DevOps and security teams.

Reduce operational risk using Kubernetes-native security controls. When possible, leverage native Kubernetes controls to enforce security policies so your own security controls and the orchestrator don’t collide.
