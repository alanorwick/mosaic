# MOSAIC

MOSAIC is built on three beliefs:
+ Help without explanation builds dependence, not empowerment.
+ Memorizing the complicated is worth little; understanding the complex is worth a lot.
+ Visualizing is organizing, representing is conveying. All good things. 

![Logo][mosaic-banner]

# Overview

MOSAIC complements the developer's toolkit by helping us:
+ Perform root cause analysis on the many things that can go wrong in a cluster
+ Logically structure the the web of K8s resources, to make it surfable
+ Automate repetitive or un-memorizable `kubectl/git/docker` chores
+ Understand the *how* and *why*s in Kubernetes without pausing the game

<p align="center">
  <img src='https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/git-quickie.gif'/>
</p>

You interact with MOSAIC through a web app that runs in your browser. The software is made of 
[three deployments](https://github.com/nectar-cs/mosaic#what-will-and-wont-go-inside-my-cluster) 
that live in your Kubernetes cluster.  
You will also be able to interact with [K8Kat](https://github.com/nectar-cs/kapi) - the brain behind MOSAIC - as a CLI. 

Note that several features are missing as this is still an alpha.   

# Installation

**Install, portforward, open**:
```shell
kubectl apply -f https://raw.githubusercontent.com/nectar-cs/mosaic/master/manifest.yaml
kubectl port-forward svc/frontend -n nectar 9000:80
kubectl port-forward svc/kapi -n nectar 5000:5000
#visit
http://localhost:9000
```

Read about the permissions used 
[here](https://github.com/nectar-cs/mosaic/blob/master/README.md#default-permissions). 
All the MOSAIC resources you created with the `apply` command above are in the `nectar` namespace. 

**To uninstall** 

```shell
kubectl delete ns/nectar
kubectl delete clusterrole/nectar-cluster-wide-role
kubectl delete clusterrolebinding/nectar-permissions
```

Note that none of the deps use resource limits at the moment. I'm waiting for some community feedback before settling on those.

Finally, keep in mind that **MOSAIC is still in alpha** so there will be bugs.   

# Root Cause Analysis

### Decision Tree Diagnosis

For common problems like services not connecting, pods not being created, permissions, MOSAIC 
has built-for-purpose wizards that diagnose the issue while showing you exactly why/how it's operating.

![decision-tree]

### Probable Cause Highlight

MOSAIC also extracts information from the API to turn your attention towards likely problems.

![pod-timeline]

Even with standard visualizations, MOSAIC conveys the notion of "it should look like X".  

![svc-overview]

### Fast Testing

In Kubernetes it's sometimes onerous to verify your work. This is especially
true with networking, which is why MOSAIC has a built in HTTP tool. 

![http-make-req]

This creates a temporary pod with a cURL-capable container, through which a request is sent to a service of your choice.  

# Workflow

### Microservice-Centric Homepage 

MOSAIC assumes that you think about your cluster as a collection of microservices. The homepage
is therefore organized in terms of the deployments in your cluster. 

![home]

### GitHub and DockerHub Integration

If you're a developer, you probably care about what's running inside a deployment. 
That's why MOSAIC lets you bind any deployment in your cluster its corresponding source and image repos.

![bulk-matching]

![prepare-docker-build]

This is thanks to the GitHub and DockerHub integrations MOSAIC lets you do. (Bitbucket and friends coming soon).

### GitOps

You can even tell MOSAIC to clone a repo, build an image, push it, and restart the its matching deployment. 
There are no triggers, as the point is to facilitate development workflows, but this is something
we can work on if the demand is there.

![integrations]

#### Customizable Workspaces 

Unlike in most dashboards, you can create permanent workspaces that you define with white/black lists.

![workspace-edit]

# Education

MOSAIC is *not* a 'learn K8s' tool, but it will to make you better at Kubernetes. 

Every action in MOSAIC features a "game plan" where it shows you a `kubectl` representation of its work.

![cmd]

There is even a smart cheat sheet for kubectl (and soon others) where commands are interpolated to fit the current resource.

![cheat-sheet]


# What Goes Inside/Outside my Cluster?

### [Frontend](https://github.com/nectar-cs/frontend)

The Frontend lives INSIDE your cluster. It's the main thing you interact with. 
It's a React app. Details [here](https://github.com/nectar-cs/frontend). 
It just runs in your browser and has zero direct contact with your infrastructure, and hence no permissions at all.

### [Kapi](https://github.com/nectar-cs/kapi)

Kapi (pronnounced '*Kahpee*', short for Kubernetes API), lives INSIDE your cluster.  
It's the Flask backend that the frontend uses to talk to your cluster. 

Note that **kapi does not use kubectl** to talk to your cluster; it uses the official python client. 

We'll be publishing [K8Kat](https://github.com/nectar-cs/kapi). - the brains behind MOSAIC - as a standalone library so check that out too.

#### Default Permissions
Kapi authenticates itself using a `ServiceAccount` bundled in 
the [manifest](https://github.com/nectar-cs/mosaic/blob/master/manifest.yaml) 
named `nectar` and authorizes itself via RBAC. Look through `ClusterRoleBinding` 
in the manifest (as you always should when putting foreign software in your cluster!); here's the simplified version:

| Resource / Namespace  | Not Nectar  | Nectar | Comments
| --- | --- | --- | --- |
| **Pods** | CRD | CRUD | *create cURL pods, create Docker build pods, delete for cleanup* |
| **Deployments** | RU | CRUD | *change replica count i.e "scale"*
| **Namespaces, Services, Events, Endpoints** | R | R |  general display, network root cause analysis, etc... |

You can obviously change the manifest.yaml with your custom perms, but MOSAIC will not fail 
gracefully it can't do things the default perms let it. You also run the risk of giving it more rights than it has now.


### Docker inside Docker

MOSAIC wraps the [official Docker image](https://hub.docker.com/_/docker) inside a deployment. 
This is used to build images from your applications' source code (see above). 

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

Far from ideal, but I couldn't find another way. If you can think of another way, please start a PR.

### Backend

The backend lives OUTSIDE your cluster. It's on a Nectar-owned server. Here's what it stores:

|   Data / Notes  |   What   |   Encrypted?    |
|   ---   |   ---   |   ---   | 
|   **Workspace Metadata**   |   name, filters  |   No   |
|   **Deployment Matchings**   |   dep name, git/docker repo names   |   No   |
|   **User**  |   email, pw   |   Yes   | 
|   **Git/Docker Hubs**   |   identifier, token   |   Yes   |

The main reason we use a remote backend is that persistent storage on k8s is still relatively hard, 
so dealing with data  problems on individual users' clusters would be a flustercluck of an ops nightmare.

# Updating

MOSAIC has a built-in self-update mechanism. When an update is available, a popup will show that lets you one-click update.

You'll see this popup quite frquently.

![](https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/sw-update.png)


# Getting involved

There's a lot more work to do, starting with polishing what exists.

After that, the planned big ticket items are listed in the [Roadmap](https://github.com/nectar-cs/mosaic/blob/master/ROADMAP.md).

## Contributing

I'll be making a group in kubernetes.slack. Otherwise, issues, pull requests, etc as usual. Don't hesitate to reach out for details.

## Joining Nectar

We're looking for cream of the crop engineers who want to create the new standard in container orchestration for the next decade.

Frontend, backend, infra, design, VP Developer Advocacy, and CTO. London, San Francisco, or remote. Drop me a line.

## What *is* Nectar?

Nectar is the company that makes MOSAIC. We're just out of stealth mode, 
have raised pre-seed, are raising seed now, and are based in London.

You just installed foreign software into your cluster to enhance it. We want to make that the norm, 
because that's how we think tomorrows's systems will be built: out of other sub systems.

But how can we trust the systems we integrate if they're so opaque? Our first step is to 
bring transparency to the cloud native executables (YAML + images). MOSAIC is the first page in that chapter.

[bulk-matching]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/bulk-matching.png
[nectar-logo]: https://storage.googleapis.com/nectar-mosaic-public/images/nectar-tomato.png "Nectar"
[mosaic-banner]: https://storage.googleapis.com/nectar-mosaic-public/images/into-the-k8set.png "Mosaic"
[bind-git-and-docker]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow-2.png
[bulk-matching]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workflow1.png
[decision-tree]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/net-debug.png
[pod-timeline]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/pod-timeline.png
[svc-overview]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/svc-overview.png
[http-make-req]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/http-op.png
[cheat-sheet]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/cheat-sheet.png
[home]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/home.png

[prepare-docker-build]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/image-op-git-1.png
[integrations]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/integrations.png
[workspace-edit]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/workspace-edit.png
[cmd]: https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/cmd.png
