# uv setup for MkDocs :sparkles:

Set up mkdocs

```sh
# Set project name
export UV_PROJECT="nuvola-docs"

# Pin Python version to a stable one (we use latest -1)
uv python pin 3.12

# Initialize project
uv init --no-package --no-readme --name "${UV_PROJECT}"

# Add MkDocs + Marterial package + Awesome Pages plugin
uv add mkdocs-material mkdocs-awesome-pages-plugin

# Install required packages
uv sync

# Create a new mkdocs site
uv run mkdocs new .

# Check & develop
uv run mkdocs serve

```
