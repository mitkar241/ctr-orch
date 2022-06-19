## Kubernetes
---
`Kubernetes` is an open source orchestrator for deploying containerized applications. It was originally developed by `Google`, inspired by a decade of experience deploying `scalable`, `reliable` systems in containers via application-oriented APIs.

Since its introduction in 2014, Kubernetes has grown to be one of the largest and most popular open source projects in the world. It has become the standard API for building cloud-native applications, present in nearly every public cloud. Kubernetes is a proven infrastructure for `distributed systems` that is suitable for cloud-native developers of all scales, from a cluster of Raspberry Pi computers to a warehouse full of the latest machines. It provides the software necessary to successfully build and deploy reliable, scalable distributed systems.

## References
---
- `Kubernetes: Up and Running, Dive into the Future of Infrastructure`

### Why Kubernetes
---
There are many reasons why people come to use containers and container APIs like
Kubernetes, but we believe they can all be traced back to one of these benefits:
- Velocity
- Scaling (of both software and teams)
- Abstracting your infrastructure
- Efficiency

### Velocity (key component)
---
The software industry deliveres software over the network via web-based services that are updated hourly. This changing landscape means that the difference between competitors is
speed with which one can develop and deploy new components and features
speed with which one can respond to innovations developed by others.

N.B. velocity is not defined in terms of simply raw speed.
- your users are always looking for iterative improvement, so they dont avail other product
- while maintaining a highly available service / constant uptime.

In this way, containers and Kubernetes can provide the tools that you need to move
quickly, while staying available. The core concepts that enable this are:
- Immutability
- Declarative configuration
- Online self-healing systems

### The Value of Immutability
---
With mutable infrastructure, changes are applied as incremental updates to an existing system. With a mutable system, the current state of the infrastructure is not represented as a single artifact, but rather an accumulation of incremental updates and changes over time.

In contrast, in an immutable system, rather than a series of incremental updates and changes, an entirely new, complete image is built, where the update simply replaces the entire image with the newer image in a single operation.

To make this more concrete in the world of containers, consider two different ways to
upgrade your software:
- One can log in to a container, run a command to download your new software, kill the old server, and start the new one.
- One can build a new container image, push it to a container registry, kill the existing container, and start a new one.

The key differentiation in these two approaches is the artifact created, and the record of how it is created. These records make it easy to understand exactly the differences in some new version and, if something goes wrong, to determine what has changed and how to fix it. Additionally, building a new image rather than modifying an existing one means the old image is still around, and can quickly be used for a rollback if an error occurs.

### Declarative Configuration
---
Immutability extends beyond containers running in cluster to the way one
describe an application to Kubernetes. Everything in Kubernetes is a declarative
configuration object that represents the desired state of the system. It is the job of
Kubernetes to ensure that the actual state of the world matches this desired state.

Much like mutable versus immutable infrastructure, `declarative configuration` is an
alternative to `imperative configuration`, where the state of the world is defined by the execution of a series of instructions rather than a declaration of the desired state of the world. While imperative commands define actions, declarative configurations define state.

To understand these two approaches, consider the task of producing three replicas of
a piece of software. With an imperative approach, the configuration would say `run
A, run B, and run C`. The corresponding declarative configuration would be `replicas
equals three`.

Because it describes the state of the world, declarative configuration does not have to be executed to be understood. Its impact is concretely declared. Since the effects of declarative configuration can be understood before they are executed, declarative configuration is far less error-prone. Further, the traditional tools of software development, such as source control, code review, and unit testing, can be used in declarative configuration in ways that are impossible for imperative instructions. The idea of storing declarative configuration in source control is often referred to as `infrastructure as code`.

### Self-Healing Systems
---
Kubernetes is an online, self-healing system. When it receives a desired state configuration, it does not simply take a set of actions to make the current state match the desired state a single time. It continuously takes actions to ensure that the current state matches the desired state. This means that not only will Kubernetes initialize your system, but it will guard it against any failures or perturbations that might destabilize the system and affect reliability.

`Traditional` : A more traditional operator repair involves a manual series of mitigation steps, or human intervention performed in response to some sort of alert. Imperative repair like this is more expensive (since it generally requires an on-call operator to be available to enact the repair). It is also generally slower, since a human must often wake up and log in to respond. Furthermore, it is less reliable because the imperative series of repair operations suffers from all of the problems of imperative management described in the previous section. Self-healing systems like Kubernetes both reduce the burden on operators and improve the overall reliability of the system by performing reliable repairs more quickly.

`Example` : If you assert a desired state of three replicas to Kubernetes, it does not just create three replicas, it continuously ensures that there are exactly three replicas. If you manually create a fourth replica, Kubernetes will destroy one to bring the number back to three. If you manually destroy a replica, Kubernetes will create one to again return you to the desired state.

`Benefit` : Online self-healing systems improve developer velocity because the time and energy you might otherwise have spent on operations and maintenance can instead be spent on developing and testing new features.

#### `Operator` : advanced form of self-healing
---
`operator` app for Kubernetes runs as a container in the cluster. The code in the operator is responsible for more targeted and advanced health detection and healing for specific softwares (e.g. MySQL), than that can be achieved via Kubernetes's generic self-healing.
