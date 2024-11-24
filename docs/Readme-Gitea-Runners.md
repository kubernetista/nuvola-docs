# Gitea Runner

# Setup in kubernetes

Get the registration token from:

Site Administration -> Actions -> Runners

- <https://git.localtest.me/admin/actions/runners>

```sh
# set env var
export RUNNER_TOKEN="aAbBcCdDeEfFgG"

# update the yaml manifests
./_scripts/gitea-runner.sh

# Commit and push
git add gitea-runner/deploy-root.yaml gitea-runner/secret-runner-token.yaml
git commit -m "update gitea runner config"
git push origin

# refresh gitea-runner app in ArgoCD (or wait a few minutes)
```

The Gitea Act Runner should become visible in Active state in the Gitea Runners page.

# Get the token and register the runner via script

```sh
#!/usr/bin/env bash

# get the gitea server pod name
POD_NAME=$(kubectl get pods -n git -l app.kubernetes.io/name=gitea -o jsonpath="{.items[0].metadata.
name}")
# get the token using the gitea cli
GITEA_RUNNER_TOKEN=$(kubectl exec --stdin=true --tty=true -n git $POD_NAME -c  gitea -- /bin/sh -c "gitea actions generate-runner-token")
echo ${GITEA_RUNNER_TOKEN}
# Register
act_runner register --no-interactive --token  ${GITEA_RUNNER_TOKEN} --instance https://git.localtest.me/
# Start
sudo act_runner daemon --config ./runner-config.yaml

```

## Runner docker images

- <https://github.com/catthehacker/docker_images/pkgs/container/ubuntu>

## Reference

- <https://gitea.com/gitea/act_runner/src/branch/main/examples/kubernetes>

### Fix 1

- <https://namesny.com/blog/gitea_actions_k3s_docker/>
- <https://github.com/catthehacker/docker_images/pkgs/container/ubuntu/282279167?tag=act-latest-20241001>

### Other fixes

- <https://gitea.com/gitea/act_runner/issues/280>
- <https://hub.docker.com/_/docker/tags?name=dind>
- <https://forum.gitea.com/t/act-runner-in-k8s-fail-to-connect-to-docker-daemon/8736/8>
  - <https://gist.github.com/mariusrugan/911f5da923c93f3c795d3e84bed9e256>

## catthehacker act runner docker images

<https://github.com/catthehacker/docker_images/tree/master>
<https://github.com/catthehacker/docker_images/pkgs/container/ubuntu/versions?filters%5Bversion_type%5D=tagged>

## Run the act-runner (external container/runner) directly

```sh
# the Act runner config files are in _assets/
cd ./_assets/

# generate a config file
act_runner generate-config > ./gitea-runner/config/runner-config.yaml

# edit the file
# ...

# start act_runner with the new config file
sudo act_runner daemon --config ./runner-config.yaml
```

### Get the certificates from Traefik

To be able to push to the Gitea container registry, it's needed to access it via HTTPS (why❓❓), so the easiest way is to build the container using docker inside the act_runner container
<!-- - ghcr.io/catthehacker/ubuntu:act-latest -->
- ghcr.io/catthehacker/ubuntu:runner-latest

 My customized version actually, running the root user, built with the dockerfile `../fastapi-demo/runner-root.dockerfile`

- ghcr.io/kubernetista/runner-root:v2

This works and has been tested already, I'm able to build a container inside the local act runner, it still creates another container in docker, where the docker client actually runs and all the good stuff.

But I still need to add the certificates to be able to push to the Gitea Container Registry.

To make it work, follow the instructions:

- <https://forum.gitea.com/t/cannot-checkout-a-repository-hosted-on-a-gitea-instance-using-self-signed-certificate-server-certificate-verification-failed/7903>

```sh
#
kubectl get configmap kube-root-ca.crt -n traefik -o jsonpath='{.data.ca\.crt}' > ca.crt
```

### Run the runner-root (internal container) with docker compose

```sh
cd _assets/
docker compose up
# docker compose up -d

```
