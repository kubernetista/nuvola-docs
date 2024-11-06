# Demo

## Create nuvola

```sh
# delete current cluster
k3d cluster delete nuvola-5

# Quick Start
```

## fastapi-uv

```sh
# test push
j dagger-test-push-local

# show recipes
j dagger-

# CI
j dagger-ci
```

## nuvola-docs

```sh
# serve docs
j serve

# build container
j cnt-build-push-restart
```

## nuvola/_assets

```sh
# register
j register-runner <token>

# start
j start-runner
```

## Go back to Nuvola 4

```sh
# Stop current cluster
k3d cluster stop ${K3D_CLUSTER}

# Start old cluster
k3d cluster start nuvola-4

# Merge kubeconfig
k3d kubeconfig merge -d nuvola-4

# check
kubectl get po -A

```
