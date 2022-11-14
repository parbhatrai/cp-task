# PodChaosMonkey

## Set up Minikube
To set up a local cluster with minikube, follow [instructions](https://minikube.sigs.k8s.io/docs/start/).

## Build PodChaosMonkey Docker image

To build the image locally, run:

```
$ docker build -t chaos:v1 .
```
## Run Dummy workload inside local cluster:

To apply the k8s manifests for dummy workload:

```
$ kubectl apply -f manifests/dummy/.
```

## Run PodChaosMonkey inside local cluster:

To apply the k8s manifests for PodChaosMonkey:
```
$ kubectl apply -f manifests/podchaosmonkey/.
```
