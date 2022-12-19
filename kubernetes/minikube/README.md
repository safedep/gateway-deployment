# Gateway Deployment in Minikube

Instructions for deploying [SafeDep Gateway](https://safedep.io/docs) in
Kubernetes using [Minikube](#).

## Prerequisite

1. [Docker](https://www.docker.com/)
2. [Minikube](https://minikube.sigs.k8s.io/docs/start/)
3. [kubectl](https://kubernetes.io/docs/reference/kubectl/)

## Usage

Bootstrap keys and config

```bash
./bootstrap.sh
```

Setup cluster in Minikube

```bash
./minikube.sh setup
```

Create a namespace and apply kubernetes manifests

```bash
kubectl create ns safedep-gateway && \
kubectl -n safedep-gateway apply -k manifests
```

## Access Gateway

Get the local URL of Gateway

```bash
minikube -p safedep-gateway service -n safedep-gateway envoy-proxy --url
```

Configure package manager to use this gateway URL.

## Teardown Cluster

Teardown Minikube cluster

```bash
./minikube.sh teardown
```

## Troubleshooting

### Gateway Service is unavailable

Verify that all the pods are running

```bash
kubectl -n safedep-gateway get pods
```

If any pod is in `CrashLoopBackOff` state or restarting frequently, check the
pod logs to identify the cause of failure

```bash
kubectl -n safedep-gateway logs -f --selector app=safedep-gateway-pdp
```

### Unable to connect to Gateway (envoy proxy)

Verify envoy proxy is deployed

```bash
kubectl -n safedep-gateway get pod,svc --selector app=envoy-proxy
```

Ensure that the `LoadBalancer` service is created for `envoy-proxy`

## Reference

* https://minikube.sigs.k8s.io/docs/handbook/accessing/
