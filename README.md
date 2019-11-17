# Nectar MOSAIC
Nectar MOSAIC does automation, root cause analysis, and education for anybody who uses Kubernetes. 

![Logo][mosaic-banner]


# Installation

You know how it goes:
```
kubectl apply -f https://github.com/nectar-cs/mosaic/tree/master/manifest.yaml
```

### Permissions


| Resource / Namespace  | Not Nectar  | Nectar | Comments
| --- | --- | --- | --- |
| **Pods** | CRD | CRUD | *create cURL pods, clean them up after* |
| **Deployments** | RU | CRUD | *change replica count i.e "scale"*
| **Services** | R | R | *no touchy* |
| * | - | - | - |

You can obviously apply your own manifest.yaml with custom perms, but MOSAIC will not fail gracefully if Kubernetes gives it access errors.

# Workflow / GitOps

MOSAIC assumes that one deployment ~= one microservice. It discovers your deployments and has you **bind** them to their respective **GitHub Repos** and **Docker Image Repos**. With this in place you choose point to deployment, choose a branch/commit, MOSAIC will build an image locally, push it to your image registry, and force the right pods to pull the image.

|  Git and Docker  |  Fast Matching Mode  |
| --- | --- |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow1.png) | ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow-2.png) |

## What Will and Won't Go Inside my Cluster?

#### [Frontend](https://github.com/nectar-cs/frontend)

The Frontend lives INSIDE your cluster. It's the main thing you interact with. It's a React app. Details [right hurr](https://github.com/nectar-cs/frontend).

#### Kapi

Kapi (pron '*Kahpee*', short for Kubernetes API), lives INSIDE your cluster. 

#### Backend

The backend lives OUTSIDE your cluster. It's on a Nectar-owned server. Here's what it stores:

|   Data / Notes  |   What   |   Encrypted?    |
|   ---   |   ---   |   ---   | 
|   **Workspace Metadata**   |   name, filters  |   No   |
|   **Deployment Matchings**   |   dep name, git/docker repo names   |   No   |
|   **User**  |   email, pw   |   Yes   | 
|   **Git/Docker Hubs**   |   identifier, token   |   Yes   |

The main reason we use a remote backend is that persistent storage on k8s is still relatively hard, making debugging users' db problems an ops nightmare.

There are a trillion things in the pipeline, but if you want a 100% self hosted version, vote here.

# Updating

MOSAIC has a built-in self-update mechanism. When an update is available, a popup will show that lets you one-click update.

[nectar-logo]: https://storage.googleapis.com/nectar-mosaic-public/images/nectar-tomato.png "Nectar"
[mosaic-banner]: https://storage.googleapis.com/nectar-mosaic-public/images/into-the-k8set.png "Mosaic"
