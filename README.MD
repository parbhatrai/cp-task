# PodChaosMonkey
This program runs inside a local cluster, interacts with the kube apiserver, and deletes one pod at random in ```workloads``` namespace on a schedule which can be changed from a configmap file in ```manifest/podchaosmonkey/chaos-config.yml``` - Currently it is set to delete a random pod every ```10``` seconds in the ```workloads``` namespace.

## Setup Minikube
To set up a local cluster with minikube, follow [instructions](https://minikube.sigs.k8s.io/docs/start/).

## Build PodChaosMonkey Docker image
To configure docker to build the image inside minikube, run:
```
$ eval $(minikube docker-env)
```

To build the image locally, run:

```
$ docker build -t chaos:v1 .
```
## Setup dummy workload inside local cluster:

To apply the k8s manifests for dummy workload:

```
$ kubectl apply -f manifests/dummy/.
```

## Run PodChaosMonkey inside local cluster:

To apply the k8s manifests for PodChaosMonkey:
```
$ kubectl apply -f manifests/podchaosmonkey/.
```
