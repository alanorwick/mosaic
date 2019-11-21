# Nectar MOSAIC
Nectar MOSAIC is a copilot Kubernetes users. It automates workflows, helps with root cause analyses, and always explains how and why it does things.

![Logo][mosaic-banner]


# Overview

MOSAIC is a web app made up of [three deployments](https://github.com/nectar-cs/mosaic#what-will-and-wont-go-inside-my-cluster) that live in your Kubernetes cluster. 

The MOSAIC alpha is primarily focused on develoment/staging workflows - the phase when you're building confidence in your cluster's behavior before production. MOSAIC is not a provisioning tool, nor is it a platform. It helps you make fewer mistakes and solve problems faster.

It is designed for intermediate-level Kubernetes users whose:
+ sub-godly proficiency in the K-verse slows them down
+ skin crawls at the thought of opaque, lock-in-hungry PaaS'es
+ ears are open at the idea of making K8s friendlier without taking over it

In short, MOSAIC is for non-K-gods who want to move faster while retaining their agency over their infra.


# Installation

You know how it goes:
```shell
kubectl apply -f https://github.com/nectar-cs/mosaic/tree/master/manifest.yaml

## expect to see ==>

namespace/nectar created
serviceaccount/nectar created
clusterrole.rbac.authorization.k8s.io/nectar-cluster-wide-role created
clusterrolebinding.rbac.authorization.k8s.io/nectar-permissions created
deployment.apps/kapi created
service/kapi created
deployment.apps/dind created
service/dind created
deployment.apps/frontend created
service/frontend created
```

Access it by portforwarding: 

```shell
kubectl port-forward svc/frontend -n nectar 9000:80
#change 9000 to whatever you want
```

Find out more about the persmissions used [here](https://github.com/nectar-cs/mosaic/blob/master/README.md#default-permissions). All the MOSAIC resources you created with the `apply` command above are in the `nectar` namespace. **To uninstall MOSAIC**, run 

```shell
kubectl delete ns/nectar
kubectl delete clusterrole/nectar-cluster-wide-role
kubectl delete clusterrolebinding/nectar-permissions
```

Note that none of the deps use resource limits at the moment. I'm waiting for some community feedback before settling on those.

# Workflow / GitOps

MOSAIC's world view is that one deployment ~= one microservice. During setup, it discovers your deployments and has you **bind** them to their respective **GitHub Repos** and **Docker Image Repos**. 

|  Git and Docker  |  Deployment x Docker x Git Matching en Masse  |   App Centric Workspace   | 
|    ---    |     ---    |   ---    |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow-2.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow1.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/home.png)   |



With this in place you can point to a deployment, choose a branch/commit, and MOSAIC build an image from source, push it to your image registry, and force the right pods to pull the image (this all takes place in your cluster).

|   Choose a Branch/Commit   |   Watch it build locally   |    See Git Commit   |
|   ---   |    ---   |    ---   |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-1.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-2.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/commit.png)   |


We think that solidifying the bond between source, container, and K8s is a powerful idea, and we'll be rolling out features that exploit the bindings more deeply.

# Root Cause Analysis

Understanding why something doesn't work in Kubernetes is a skill in and of itself. MOSAIC proposes a set of features to assist in uncovering the roots of problems.

|  Network Debug Wizard  |  Pod Status/Event Meaning    |
|    ---     |     ---    |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/net-debug.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/pod-timeline.png)   |



MOSAIC also speeds up onerous tasks key to introspection such as creating one time pods to cURL your services, sending quick shell commands, force-pulling images, and checking logs. 

|    HTTP Sender    |      Shell Commands    |    Image Force Pull     |
|    ---    |    ---    |     ---    |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/http-op.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/cmd.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/force-pull.png)   |


# Education

MOSAIC is *not* a 'learn K8s' tool, but it does try to make its user better at Kubernetes. We go about this by *involving* the user in every action and decision taken by the software.

In the Network Debug Wizard for example, even though MOSAIC is driving the bus, tells you *why* it's running this test, and even suggests reading material at the end.

In just about every feature in MOSAIC, if there's an interaction with Kubernetes, a "Game Plan" view will show how to do this yourself with kubectl and [K8Kat](https://github.com/nectar-cs/kapi).



# What's Inside/Outside my Cluster?

### [Frontend](https://github.com/nectar-cs/frontend)

The Frontend lives INSIDE your cluster. It's the main thing you interact with. It's a React app. Details [here](https://github.com/nectar-cs/frontend). It just runs in your browser and has zero direct contact with your infrastructure, and hence no permissions at all.

### [Kapi](https://github.com/nectar-cs/kapi)

Kapi (pronnounced '*Kahpee*', short for Kubernetes API), lives INSIDE your cluster.  It's the Flask backend that the frontend uses to talk to your cluster. 

Note that **kapi does not use kubectl** to talk to your cluster; it uses the official python client. 

We'll be publishing [K8Kat](https://github.com/nectar-cs/kapi). - the brains behind MOSAIC - as a standalone library so check that out too.

#### Default Permissions
Kapi authenticates itself using a `ServiceAccount` bundled in the [manifest](https://github.com/nectar-cs/mosaic/blob/master/manifest.yaml) named `nectar` and authorizes itself via RBAC. Look through `ClusterRoleBinding` in the manifest (as you always should when putting foreign software in your cluster!); here's the simplified version:

| Resource / Namespace  | Not Nectar  | Nectar | Comments
| --- | --- | --- | --- |
| **Pods** | CRD | CRUD | *create cURL pods, create Docker build pods, delete for cleanup* |
| **Deployments** | RU | CRUD | *change replica count i.e "scale"*
| **Namespaces** | R | CRU | *for creating the initial nectar ns*
| **Services, Events, Endpoints** | R | R |  general display, network root cause analysis, etc... |

You can obviously change the manifest.yaml with your custom perms, but MOSAIC will not fail gracefully it can't do things the default perms let it. You also run the risk of giving it more rights than it has now.


### Docker inside Docker

MOSAIC wraps the [official Docker image](https://hub.docker.com/_/docker) inside a deployment. This is used to build images from your applications' source code (see above). 

If you want to get rid of this to cut costs, the easiest way is to scale it down through MOSAIC's GUI. Equivalently, with kubectl:

```bash
kubectl scale deploy dind --replicas=0 -n nectar
kubectl delete deploy dind -n nectar #or more violently
```

Note that this deployment gives its container root access: 
```yaml
      containers:
        - name: dind
          image: docker:18.05-dind
          securityContext:
            privileged: true
          volumeMounts:
            - name: dind-storage
              mountPath: /var/lib/docker
```

Far from ideal, but I couldn't find another way. If you know how to get Docker running in your cluster without this, let me know (xavier@codenectar.com).

### Backend

The backend lives OUTSIDE your cluster. It's on a Nectar-owned server. Here's what it stores:

|   Data / Notes  |   What   |   Encrypted?    |
|   ---   |   ---   |   ---   | 
|   **Workspace Metadata**   |   name, filters  |   No   |
|   **Deployment Matchings**   |   dep name, git/docker repo names   |   No   |
|   **User**  |   email, pw   |   Yes   | 
|   **Git/Docker Hubs**   |   identifier, token   |   Yes   |

The main reason we use a remote backend is that persistent storage on k8s is still relatively hard, so dealing with data  problems on individual users' clusters would be a flustercluck of an ops nightmare.

# Updating

MOSAIC has a built-in self-update mechanism. When an update is available, a popup will show that lets you one-click update.

You'll see this popup quite frquently.

![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/sw-update.png)

[nectar-logo]: https://storage.googleapis.com/nectar-mosaic-public/images/nectar-tomato.png "Nectar"
[mosaic-banner]: https://storage.googleapis.com/nectar-mosaic-public/images/into-the-k8set.png "Mosaic"


# Meta

## What *is* Nectar?

Nectar is the company that makes MOSAIC. We're just out of stealth mode, have recently raised pre-seed, and are based in London.

Kubernetes is both complex and complicated.

Complex is why we love it - it's what makes orchestration powerful - it's inherent.

Complicated is why some hate it - orchestration's greatest weakness - but *we* believe it's *not* inherent.

That's why **Nectar's mission** is to make orchestion *orderly*.


## Getting involved

If this gets you excited, if you're feeling crazy, have some water. After that, drop me a line at xavier@codenectar.com or on the K8s slack.

We're looking for engineers who want to create the new standard in container orchestration for the next decade.

Frontend, backend, infra, design, VP Developer Advocacy, and CTO. London, San Francisco, or remote. Big boy equity. Drop me a line.
