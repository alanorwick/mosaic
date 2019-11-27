# MOSAIC Roadmap
<p align="center">
  <img src='https://storage.googleapis.com/nectar-mosaic-public/images/pub-site/ash-on-charizard.png'/>
</p>

The following features in order of planned release. As a benchmark, 
we aim to have Team Support done by Jan 2020 and Playground by April. 

## Local Auth and Storage

A remote backend isn't right for a lot of individuals and teams. The design decision to host storage
remotely is a result of the perceived added complexity of having PersistentVolumes in every user's cluster.

But we realize this is a huge (and legitimate) barrier to adoption, so we will be building in the 
option to opt for local storage.


## Team Support

For MOSAIC to work well in teams, we'll be adding a tool you run at install time that lets you make 
MOSAIC **inherit RBAC for any given cluster user**. This means:
+ Users will not be able to act beyond their vanilla RBAC privileges using MOSAIC
+ There won't be a need for some proprietary auth scheme for MOSAIC 

## Cover All Kubernetes Resources

More of the same MOSAIC, but covering more Kubernetes resources:
+ Ingress and Egress
+ NetworkPolicies 
+ StatefulSets
+ PersistentVolumes and friends
+ ConfigMaps and Secrets

## Playground: Ultrafast Experimentation

Why is it that with Python/Ruby/etc you can fire up an interpreter,
try things, learn, and exit, but in Kubernetes it takes forever?

We think there are three main reasons:
+ 99% of YAML for K8s resources is impossible to write without copy-pasta. And there's a lot of it.
+ The friction involved in running our test source code on foreign Docker images
+ All things state. Make a temp namespace? Need to make a ServiceAccount? Remember to cleanup...       

I often don't *feel like* trying out new things out in Kubernetes because 
I know the overhead stands in the way. 

The goal with Playground is to eliminate the 'quicksand' effect K8s
has on devs and experiment at Ruby/Python speeds.

You choose a Kocktail - YAML/Dockerfile/Source bundle - it runs in your cluster, you can edit "live", and 
cleanup is auto-managed. Kocktails are community-provided and exist to put you put you 
in control in various infra-scenarios without having to do the upfront YAML chores.  

Think Helm, but optimized for get-in, get-out experimentation.

![](https://storage.googleapis.com/nectar-mosaic-public/images/soons/playground/playground-1.png)

![](https://storage.googleapis.com/nectar-mosaic-public/images/soons/playground/playground-2.png)

## Laboratory: Deep, Repeatable Infra Testing

With the growing complexity of clusters, it's kind of shocking we don't have repeatable
ways to make sure the cluster behaves the way we expect it to. 

Not the behavior of the apps in the cluster, but the cluster itself, i.e the thing we just 
fed a million lines of YAML to and *believe* works okay.

Laboratory is for encoding such behavior tests.

![](https://storage.googleapis.com/nectar-mosaic-public/images/soons/experiments/experiments-1.png)

![](https://storage.googleapis.com/nectar-mosaic-public/images/soons/experiments/experiments-3.png)

## Regression Prevention

Putting pass/fail conditions around our Laboratory experiments.

![](https://storage.googleapis.com/nectar-mosaic-public/images/soons/regression-testing/regression-testing-1.png)