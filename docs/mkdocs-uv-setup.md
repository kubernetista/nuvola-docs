# uv setup for MkDocs :sparkles:

Some icons/emojis:

- :fontawesome-regular-face-laugh-wink:{ .emoji }

- :octicons-heart-fill-24:{ .heart }

- :fontawesome-brands-youtube:{ .youtube }

```sh
# Set project name
export UV_PROJECT="nuvola-docs"

# Pin Python version to the stable one (latest - 1)
uv python pin 3.12

# Initialize project
uv init --no-package --no-readme --name "${UV_PROJECT}"

# Add MkDocs + Marterial package
uv add mkdocs-material

# Install required packages
uv sync

# Create a new mkdocs site
uv run mkdocs new .

# Check & develop
mkdocs serve

```
