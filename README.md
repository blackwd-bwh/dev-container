# Dev Container Environment

This project provides a ready-to-use development container for building and working with Python, Node.js, AWS, and Docker tooling.\
It includes a complete environment with Zsh, Powerlevel10k, tmux, and mounted personal dotfiles for a consistent development experience across machines.

## Features

- **Base**: Ubuntu 22.04
- **Shell**: Zsh with Oh My Zsh and Powerlevel10k theme
- **Terminal Multiplexer**: tmux auto-start on shell login
- **AWS CLI**: Installed and preconfigured via bind mount
- **Python**: 3.11 with `uv` package manager (fast alternative to pip)
- **Node.js**: 22.x via NodeSource
- **AWS CDK**: Installed globally via npm
- **Development Tools**: tree, bat, fd, htop, jq, ripgrep, build-essential
- **VS Code Extensions**:
  - Python
  - Docker
  - ESLint
  - GitLens
  - Remote Containers
  - Prettier

## Configuration

- **AWS Credentials**: Your local `~/.aws` directory is mounted into the container at `/root/.aws`.
- **Dotfiles**: Your local dotfiles repo is mounted into the container at `/root/.dotfiles`.
- **Zsh**: Configured with Oh My Zsh, Powerlevel10k theme, and git plugin.
- **Tmux**: Automatically starts when opening a shell session.
- **Git Config**: `.gitconfig` from your dotfiles is symlinked into `/root/.gitconfig`.

## Project Structure

```text
dev-container/
  ├── .devcontainer/
  │     ├── Dockerfile         (Builds the container)
  │     ├── devcontainer.json  (VS Code settings and mounts)
  │     └── setup.sh           (Optional: symlink dotfiles inside container)
  ├── dotfiles/
  │     ├── .zshrc
  │     ├── .p10k.zsh
  │     ├── .tmux.conf
  │     ├── .gitconfig
  │     └── install.sh         (Optional: symlink script)
  ├── README.md
  └── LICENSE (optional)
```

## Usage

To build and run the container manually:

```bash
docker build -t my-dev-container .
docker run -it --rm \
  -v ~/dev-container:/workspaces/dev-container \
  -v ~/.aws:/root/.aws \
  -v ~/code/dotfiles:/root/.dotfiles \
  my-dev-container
```

Or, to use Visual Studio Code:

- Open the `dev-container/` folder.
- Accept the prompt to "Reopen in Container."
- Your environment will automatically have Zsh, tmux, AWS CLI, and dotfiles ready.
