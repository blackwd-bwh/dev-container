# My Dev Container

This is a preconfigured development environment with:

- Python 3.12 + pip + uv
- Node.js 22.x + npm
- AWS CLI v2 + AWS CDK
- Docker CLI
- tmux + personal config
- zsh + oh-my-zsh + Powerlevel10k
- Helpful tools: `bat`, `fd`, `tree`, `ripgrep`, `htop`, etc.

## Setup Instructions

1. Clone this repo locally.
2. Open the folder in VS Code.
3. You should be prompted to "Reopen in Container" — click it.
4. Wait for container to build (may take a few minutes the first time).
5. Done! You’re now inside your dev container.

**Notes:**
- Your `~/.aws` credentials are automatically mounted into the container.
- Your `.tmux.conf`, `.zshrc`, and `.p10k.zsh` configs are baked into the container.

## Optional
- Update your tmux, zsh, or Powerlevel10k configs by copying in new versions and rebuilding the container.
