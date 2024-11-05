# Quick Start

## Nuvola ☁️ is a Local Developer Platform

## 1. Create a Kubernetes cluster

Create a Kubernetes cluster with k3d/k3s

```sh
# Create (with the config already created and updated)
cd nuvola

# Set it explicitly or loaded from direnv .envrc
# export K3D_CLUSTER="nuvola-1"
echo ${K3D_CLUSTER}

# Generate the k3d configuration (using a Just recipe)
just k3d-cluster-generate-config

# Create the k3d cluster
just k3d-cluster-create

```

## 2. Wait ⏳

#### Wait a few minutes to let ArgoCD deploy all the resources

```
# Watch pod creation
kubectl get pod -n vault -w

# Wait for the git namespace to be available
kubectl get pod -n git -w
```

It usually takes between 2 and 5 minutes.

In the mean time, you could check ArgoCD deployment progesess, either with the CLI, or
from the web UI:

```sh
# Get the ArgoCD initial password
argocd admin initial-password -n argocd | head -n 1

# Login
argocd login --insecure --grpc-web --username admin argocd.localtest.me

# Check progress
argocd app wait apps --health --sync

# port forward
kubectl port-forward service/argocd-server -n argocd 8080:443

# Open the ArgoCD web UI and login with user "admin" and the password above
open https://localhost:8080

```

#### Once the ArgoCD apps are synced, proceed creating the secrets

```sh
# Create the required secrets
kubectl apply -f secrets/

```

## Certificate for HTTPS (using kixelated/mkcert)

!!! todo
    ☑️ TODO: replace the steps below with a container or a Dagger module ☑️

Generate a new TLS certificate with kixelated/mkcert, and add it tp Traefik.

The certificate will last 20 days (for security reasons) but you can adjust it.

!!! warning
    🛫 If you already have a valid certificate, for example because you already generated
    it following the steps below, then jump to [__step 3__](#3-install-the-certificates-and-reload-traefik) 🛫

## 3. Generate the certs

```sh
# Generate the certs with expiration in 20gg using kixelated/mkcert
cd kixelated-mkcert

# Generate
./mkcert -days=20 "*.localtest.me"

# Check
openssl x509 -in _wildcard.localtest.me.pem -noout -text | bat -l yaml

# Copy the files to the nuvola repo, in a directory excluded from git
cp _wildcard.localtest.me* ../_nuvola/nuvola/_assets/secrets/

# Switch to the directory containing the certs
cd nuvola/_assets/secrets

# Rename
CERT_NAME="wildcard-localtest-me"
mv _wildcard.localtest.me.pem  ${CERT_NAME}.pem
mv _wildcard.localtest.me-key.pem  ${CERT_NAME}-key.pem

# Generate kubernetes secret with the cert ${CERT_NAME}.pem
kubectl create -n default secret tls ${CERT_NAME}-tls \
    --cert=${CERT_NAME}.pem --key=${CERT_NAME}-key.pem \
    --dry-run=client -o yaml | kubectl neat > secret-tls-${CERT_NAME}.yaml
```

## 4. Install the certificates and reload Traefik

```sh
# Switch to the directory containing the certs
cd nuvola/_assets/secrets

# Create the secret containing the TLS certificate and its key
CERT_NAME="wildcard-localtest-me"
kubectl apply -f secret-tls-${CERT_NAME}.yaml

# Restart Traefik to load the new cert
kubectl rollout restart deployment traefik -n traefik

```

## 5. Configure Vault and External Secrets

!!! info
    Vault is currently being configured in Development mode, so at every restart
    of the container the secrets and the configuration are reset to the default values.

    Therefore, the steps below will be required at every Docker Desktop or laptop restart.

Without configuring Vault and ExternalSecrets many features will be missing, so:

```sh
# Switch to the ExternalSecrets helm projext
cd external-secrets-helm

# Wait for vault to be ready
kubectl wait -n vault --for=condition=ready pod -l app.kubernetes.io/instance=vault

# Run the setup script using Just
just setup-vault-eso-test-app
```

## 🎉 Configuration completed

Congratulations, your Nuvola is ready! ☁️

Explore the [documentation home](/) to discover the full range of tools Nuvola offers.

__☁️ Enjoy!__

## Troubleshooting

If some resources are unavailable wia the browser, it could be due to Traefik: restart it.

```sh
# Restart Traefik
kubectl rollout restart deployment traefik -n traefik
```
