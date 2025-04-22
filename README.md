# Dev Container Environment

This project provides a ready-to-use development container for building and working with Python, Node.js, AWS, and Docker tooling.  
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

## Requirements

Before using this Dev Container:

- Clone your dotfiles repository inside WSL:

  ```bash
  mkdir -p ~/code
  cd ~/code
  git clone git@scm.bwhhg.io:users/blackwd/repos/dotfiles.git
  ```

- Verify that your AWS credentials are located at `~/.aws/` inside WSL.
- Ensure Docker Desktop with WSL 2 backend is running.

## Configuration

- **AWS Credentials**: Your local `~/.aws` directory is mounted into the container at `/root/.aws`.
- **Dotfiles**: Your local `~/code/dotfiles` directory is mounted into the container at `/root/.dotfiles`.
- **Zsh**: Configured with Oh My Zsh, Powerlevel10k theme, and git plugin.
- **Tmux**: Automatically starts when opening a shell session.
- **Git Config**: `.gitconfig` from your dotfiles is symlinked inside the container.

## Project Structure

```text
dev-container/
├── .devcontainer/
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── dotfiles_setup.sh
├── .gitignore
├── README.md
```

_(No dotfiles are stored directly inside this repo — they are mounted at runtime.)_

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

## Notes

- Node.js and Python are installed from official sources, not apt.
- AWS credentials are **mounted**, not baked into the image for security.
- Dotfiles are **mounted** from your WSL filesystem, not copied.

## Troubleshooting

- If tmux doesn't start, check that `$TERM` is set correctly and that `tmux` is installed.
- If AWS CLI fails, verify that your local `~/.aws` folder has valid credentials.
- If dotfiles are missing, verify that `~/code/dotfiles` exists inside WSL.
