# Nectar MOSAIC
Nectar MOSAIC is a copilot for use developers who use Kubernetes. It automates workflows, helps with root cause analyses, and always explains how and why it does things, so you get better at Kubernetes too.

![Logo][mosaic-banner]


# Overview

MOSAIC is a web app made up of [three deployments](https://github.com/nectar-cs/mosaic#what-will-and-wont-go-inside-my-cluster) that live in your Kubernetes cluster. 

This MOSAIC alpha is primarily focused on develoment/staging workflows - the phase when you're trying to gain confidence in your cluster's behavior before production. MOSAIC is [not a](https://github.com/nectar-cs/mosaic#meta) provisioning tool, [nor is it](https://github.com/nectar-cs/mosaic#meta) a platform. It helps you make fewer mistakes and solve problems faster.

It is designed for devs with intermediate Kubernetes skills whose:
+ sub-godly proficiency in the K-verse hinders their total productivity
+ skin crawls when they hear about opaque, lock-in-hungry PaaS'es
+ ears rejoice regarding software that make K8s friendlier without taking over it

In short, MOSAIC is for non-K-gods who want to move faster while their retaining agency over their infra.


# Installation

You know how it goes:
```shell
kubectl apply -f https://github.com/nectar-cs/mosaic/tree/master/manifest.yaml
```

Access it by portforwarding: 

```shell
kubectl port-forward 9000:80 svc/frontend -n nectar
#change 9000 to whatever you want
```

# Workflow / GitOps

MOSAIC's world view is that one deployment ~= one microservice. During setup, it discovers your deployments and has you **bind** them to their respective **GitHub Repos** and **Docker Image Repos**. 

|  Git and Docker  |  Deployment x Docker x Git Matching en Masse  |   App Centric Workspace   | 
|    ---    |     ---    |   ---    |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow-2.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow1.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/home.png)   |

With this in place you can point to a deployment, choose a branch/commit, and MOSAIC will build an image [locally](https://github.com/nectar-cs/mosaic#docker-inside-docker), push it to your image registry, and force the right pods to pull the image.

|   Choose a Branch/Commit   |   Watch it build locally   |    See Git Commit   |
|   ---   |    ---   |    ---   |
| ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-1.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-2.png)    |    ![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/commit.png)   |

We think that solidifying the bond between source, container, and K8s is a powerful idea, and we'll be rolling out features that exploit the bindings we're created more deeply.

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

#### Default Permissions
Kapi authenticates itself using a `ServiceAccount` bundled in the [manifest](https://github.com/nectar-cs/mosaic/blob/master/manifest.yaml) named `nectar`  (`kubectl get sa/nectar`). The `ClusterRoleBinding` also in the manifest gives Kapi the following permissions:

| Resource / Namespace  | Not Nectar  | Nectar | Comments
| --- | --- | --- | --- |
| **Pods** | CRD | CRUD | *create cURL pods, create Docker build pods, delete for cleanup* |
| **Deployments** | RU | CRUD | *change replica count i.e "scale"*
| **Services, Events, Endpoints** | R | R |  general display, network root cause analysis, etc... |

You can obviously change the manifest.yaml with your custom perms, but MOSAIC will not fail gracefully it can't do things the default perms let it. You also run the risk of giving it more rights than it has now.


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

You'll see this pretty often (assuming there are fires to fight during the alpha).

![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/sw-update.png)

[nectar-logo]: https://storage.googleapis.com/nectar-mosaic-public/images/nectar-tomato.png "Nectar"
[mosaic-banner]: https://storage.googleapis.com/nectar-mosaic-public/images/into-the-k8set.png "Mosaic"

# Meta

# Getting involved

If you this gets you excited, if you're feeling crazy right now, first hydrate yourself, do not attempt to drive. After that though, drop me a line at xavier@codenectar.com.



### Wth is Nectar?



# What's to Come
