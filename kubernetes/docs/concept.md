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
