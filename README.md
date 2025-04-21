# Dev Container Environment

This repository contains a full-featured development container setup, designed for cloud and backend engineering work.

## Features

- **Base**: Ubuntu 22.04
- **Shell**: Zsh with Oh My Zsh and Powerlevel10k theme
- **Terminal Multiplexer**: Tmux auto-start on shell login
- **AWS CLI**: Installed and preconfigured via bind mount
- **Python**: 3.11 with `uv` package manager (fast alternative to pip)
- **Node.js**: 22.x via NodeSource
- **AWS CDK**: Installed globally via NPM
- **VS Code Extensions**:
  - Python
  - Docker
  - ESLint
  - GitLens
  - Remote Containers
  - Prettier

## Configuration

- **AWS Credentials**: Your local `~/.aws` directory is mounted into the container at `/root/.aws`.
- **Zsh**: Configured with Oh My Zsh, Powerlevel10k theme, and git plugin.
- **Tmux**: Automatically starts when opening a shell session.

## Usage

To build and run the container manually:

```bash
docker build -t my-dev-container .
docker run -it --rm \
  -v ~/dev-container:/workspaces/dev-container \
  -v ~/.aws:/root/.aws \
  my-dev-container
