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

|  Git and Docker  |  Fast Matching Mode  |
| --- | --- |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow1.png) | ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow-2.png) |

With this in place you can point to a deployment, choose a branch/commit, and MOSAIC will build an image [locally](https://github.com/nectar-cs/mosaic#docker-inside-docker), push it to your image registry, and force the right pods to pull the image.

# Root Cause Analysis

MOSAIC 

## What Will and Won't Go Inside my Cluster?

### [Frontend](https://github.com/nectar-cs/frontend)

The Frontend lives INSIDE your cluster. It's the main thing you interact with. It's a React app. Details [here](https://github.com/nectar-cs/frontend).

### [Kapi](https://github.com/nectar-cs/kapi)

Kapi (pronnounced '*Kahpee*', short for Kubernetes API), lives INSIDE your cluster.  It's the Flask backend the frontend uses to talk to your cluster. We'll be publishing K8Kat - the brains behind MOSAIC - as a standalone library. Details [here](https://github.com/nectar-cs/kapi).

### Docker inside Docker

The manifest also includes a deployment for the [official Docker image](https://hub.docker.com/_/docker). This is used to build images from your applications' source code (see above). The image is inside a deployment so it is does run all the time. The reason being is speed: if we made one-time every time you needed to build, the docker image cache would get wiped and you'd have to build every build from scratch. 

If you want to get rid of this, the easiest way is through MOSAIC, i.e make a Workspace filtered by namespace = nectar and then scale `dind` down to 0. Else, with kubectl:

```bash
kubectl scale deploy dind --replicas=0 -n nectar
kubectl delete deploy dind -n nectar #or more violently
```

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
