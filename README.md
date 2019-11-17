# Nectar MOSAIC
Nectar MOSAIC does automation, root cause analysis, and education for anybody who uses Kubernetes. 

![Logo][mosaic-banner]

# Workflow / GitOps

MOSAIC assumes that one deployment ~= one microservice. As such, it starts discovering your deployments and have you **bind** them to their respective **GitHub Repos** and **Docker Image Repos**. 

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

# Updating

MOSAIC has a built-in self-update mechanism. When an update is available, a popup will show that lets you one-click update

[nectar-logo]: https://storage.googleapis.com/nectar-mosaic-public/images/nectar-tomato.png "Nectar"
[mosaic-banner]: https://storage.googleapis.com/nectar-mosaic-public/images/into-the-k8set.png "Mosaic"
