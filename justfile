# Justfile

# Variables
# IMAGE_NAME := "fastapi-uv:latest"

# default:
#     echo 'Hello, world!'

# List 📜 all recipes (default)
help:
    @just --list

# Serve the documentation locally for preview / development
serve:
    @#cd ./docs && mkdocs serve
    @uv run mkdocs serve
