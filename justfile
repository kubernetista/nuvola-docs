# Justfile

# Variables
# IMAGE_NAME := "fastapi-uv:latest"
CONTAINER_TAG:= "$(git describe --tags --abbrev=4 HEAD --always)"
PROJECT_NAME:= "nuvola-docs"

# default:
#     echo 'Hello, world!'

# List 📜 all recipes (default)
help:
    @just --list

# Serve the documentation locally for preview / development
serve:
    @#cd ./docs && mkdocs serve
    @uv run mkdocs serve

# Build the documentation for distribution
build *args:
    @uv run mkdocs build {{args}}

# Built the documentation and then build the container
cnt-build:
    @echo "Building the container with tag: {{CONTAINER_TAG}}"
    @just build
    @#docker build -t $(IMAGE_NAME) .
    docker build . -t {{PROJECT_NAME}} -t ghcr.io/kubernetista/{{PROJECT_NAME}}:latest \
        -t ghcr.io/kubernetista/{{PROJECT_NAME}}:{{CONTAINER_TAG}} --build-arg CONTAINER_TAG={{CONTAINER_TAG}}

# Push the container to GitHub Container Registry
cnt-push:
    @#docker push $(IMAGE_NAME)
    docker push ghcr.io/kubernetista/{{PROJECT_NAME}}:{{CONTAINER_TAG}}
    docker push ghcr.io/kubernetista/{{PROJECT_NAME}}:latest

# Restart the container (deleting the deployment, that will be recreated by ArgoCD)
cnt-restart:
    @kubectl delete deployment nginx-docs -n docs

# Build and push the container
cnt-build-push: cnt-build cnt-push

# Build, push and restart the container
cnt-build-push-restart: cnt-build cnt-push cnt-restart
