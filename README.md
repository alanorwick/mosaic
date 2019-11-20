# Nectar MOSAIC
Nectar MOSAIC does automation, root cause analysis, and education for anybody who uses Kubernetes. 

![Logo][mosaic-banner]


# Overview

MOSAIC is a web app that lives in your Kubernetes cluster. The goal is to make life better for developers of all Kubernetes skills who use Kubernetes every day:
- automating onerous commands in common workflows
- directly and indirectly help troubleshoot common issues 
- always explaining its work, hopefully teaching you something

Visualize does not mean hide. Automate does not mean unlearn.

# Installation

You know how it goes:
```bash
kubectl apply -f https://github.com/nectar-cs/mosaic/tree/master/manifest.yaml
```

Access it by portforwarding: 

```bash
kubectl port-forward 9000:80 svc/frontend -n nectar
#change 9000 to whatever you want
```

You can also have the frontend service exposed on public web, but that's always a risk:

```bash
kubectl delete svc/frontend -n nectar
kubectl expose deployment/frontend --type=LoadBalancer --name=frontend -n nectar
```


### Default Permissions


| Resource / Namespace  | Not Nectar  | Nectar | Comments
| --- | --- | --- | --- |
| **Pods** | CRD | CRUD | *create cURL pods, clean them up after* |
| **Deployments** | RU | CRUD | *change replica count i.e "scale"*
| **Services** | R | R | - |
| **Events** | R | R | - |
| * | - | - | - |

You can obviously modify the manifest.yaml with custom perms, but MOSAIC will not fail gracefully if Kubernetes gives it access errors. You also run the risk of giving it more rights than it has now.

# Workflow / GitOps

MOSAIC assumes that one deployment ~= one microservice. It discovers your deployments and has you **bind** them to their respective **GitHub Repos** and **Docker Image Repos**. 

|  Git and Docker  |  Fast Matching Mode  |   App Centric Workspace   | 
|    ---    |     ---    |   ---    |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow-2.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git1.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/home.png)   |

With this in place you can point to a deployment, choose a branch/commit, and MOSAIC will build an image [locally](https://github.com/nectar-cs/mosaic#docker-inside-docker), push it to your image registry, and force the right pods to pull the image.

|   Choose a Branch/Commit   |   Watch it build locally   |    See Git Commit   |
|   ---   |    ---   |    ---   |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-1.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-2.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/commit.png)   |


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

While MOSAIC is *not* a 'learn K8s' tool, it does try to make its user better at Kubernetes. We go about this by *involving* the user in every action and decision taken by the software.

In the Network Debug Wizard for example, even though MOSAIC is driving the bus, tells you *why* it's running this test, and even suggests reading material at the end.

In just about every feature in MOSAIC, if there's an interaction with Kubernetes, a "Game Plan" view will show how to do this yourself with kubectl and [K8Kat](https://github.com/nectar-cs/kapi).



## What Will and Won't Go Inside my Cluster?

### [Frontend](https://github.com/nectar-cs/frontend)

The Frontend lives INSIDE your cluster. It's the main thing you interact with. It's a React app. Details [here](https://github.com/nectar-cs/frontend).

### [Kapi](https://github.com/nectar-cs/kapi)

Kapi (pronnounced '*Kahpee*', short for Kubernetes API), lives INSIDE your cluster.  It's the Flask backend that the frontend uses to talk to your cluster. 

Note that **kapi does not use kubectl** to talk to your cluster; it uses the official python client. All "Game Plan" kubectl commands displayed in the frontend 

We'll be publishing [K8Kat](https://github.com/nectar-cs/kapi). - the brains behind MOSAIC - as a standalone library so check that out too.

### Docker inside Docker

MOSAIC uses wraps the [official Docker image](https://hub.docker.com/_/docker) inside its own deployment. This is used to build images from your applications' source code (see above). 

If you want to get rid of this to cut costs, the easiest way is through MOSAIC, i.e make a Workspace filtered by namespace = nectar and then scale `dind` down to 0. Else, with kubectl:

```bash
kubectl scale deploy dind --replicas=0 -n nectar
kubectl delete deploy dind -n nectar #or more violently
```

Note that if you delete it, MOSAIC will not understand that the deployment is missing, and will crash when you ask it to build a Git commit.

### Backend

The backend lives OUTSIDE your cluster. It's on a Nectar-owned server. Here's what it stores:

|   Data / Notes  |   What   |   Encrypted?    |
|   ---   |   ---   |   ---   | 
|   **Workspace Metadata**   |   name, filters  |   No   |
|   **Deployment Matchings**   |   dep name, git/docker repo names   |   No   |
|   **User**  |   email, pw   |   Yes   | 
|   **Git/Docker Hubs**   |   identifier, token   |   Yes   |

The main reason we use a remote backend is that persistent storage on k8s is still relatively hard, so dealing with data  problems on individual users' clusters would be a flustercluck an ops nightmare.

There are a trillion things in the pipeline, but if you want a 100% self hosted version, vote here.

# Updating

MOSAIC has a built-in self-update mechanism. When an update is available, a popup will show that lets you one-click update.

[nectar-logo]: https://storage.googleapis.com/nectar-mosaic-public/images/nectar-tomato.png "Nectar"
[mosaic-banner]: https://storage.googleapis.com/nectar-mosaic-public/images/into-the-k8set.png "Mosaic"
