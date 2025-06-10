# Python 3.13 Dev Container

This repository provides a very small dev container image based on `python:3.13-slim`.
The container simply sets `/workspace` as the working directory and runs `sleep infinity`
so you can attach a shell from your editor.

## Project structure

```
src/python313/.devcontainer/
├── Dockerfile
└── devcontainer.json
```

`devcontainer.json` configures VS Code to use this image without additional
extensions or post-create steps.

## Usage

### With VS Code

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open this folder in VS Code and choose **Reopen in Container** when prompted.

### Manual build

```bash
docker build -t python313 src/python313/.devcontainer
docker run -it --rm python313
```
