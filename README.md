# Rust Dev Container (`ubuntu-rust-dev`)

This dev container is tailored for Rust development, with a focus on CLI and JetBrains RustRover workflows. Unlike other containers in this series, it is not optimized for use with VS Code, but instead supports a clean Docker-based toolchain and SSH-aware terminal environment.

---

## Features

- **Base**: Ubuntu 22.04
- **Shell**: Zsh with Oh My Zsh and Powerlevel10k theme
- **Terminal Multiplexer**: tmux auto-start
- **Rust**: Installed via rustup (includes rustc, cargo, rustfmt, clippy)
- **AWS CLI v2**: Preinstalled
- **Development Tools**: build-essential, jq, htop, tree, bat, ripgrep, etc.
- **SSH Agent**: Persistent, secure key management with shared socket
- **Dotfiles**: Automatically cloned and configured via bootstrap script

---

## Usage: CLI and RustRover

### 🔧 With Devcontainer CLI

To build and run the container from WSL:

```bash
cd ~/code/dev-container
devcontainer up --workspace-folder . --name rustrover-dev
```

To open a shell inside:

```bash
docker exec -it rustrover-dev zsh
```
---

### 🧠 RustRover Integration

RustRover supports Dev Containers through a built-in interface.

To launch the container:

1. Right-click the `.devcontainer/` folder in the Project view
2. Select:
   ```
   Dev Containers → Create Dev Container and Mount Sources...
   ```
3. RustRover will:
   - Parse your `.devcontainer.json`
   - Build and start the container
   - Mount your project into it
   - Open a new IDE context attached to the container

This approach allows you to work inside a Docker-based Rust environment without using the "Remote Development" workflow.

💡 Choose **"Mount Sources"** if you want to keep editing your real files on disk.

---

## Choosing Between Mount Sources and Clone Sources

When creating a container, you have two main options for how your code is handled:

### ✅ Option 1: Mount Sources (Recommended for RustRover)

```bash
devcontainer up --workspace-folder ~/code/myproject
```

- Uses your **existing local files**
- Changes made in the container update your real files
- You can edit with RustRover or any editor outside the container
- When the container is stopped or deleted, your code is safe

✅ **Use this when you want to do real development and keep your files.**

---

### 📦 Option 2: Clone Sources

```bash
devcontainer up --clone-repo https://github.com/youruser/myproject.git
```

- Clones the repo directly **into the container**
- Your local files are untouched
- Changes are kept inside the container unless you push to Git
- If the container is deleted, your changes are lost

🟡 **Use this only when you want an isolated, temporary environment.**

---

## SSH Agent Setup

- Agent socket: `/root/.ssh/ssh-agent.sock`
- Environment: `/root/.ssh/agent_env`
- Loaded via `start_ssh_agent.sh` and sourced in shell
- Works across tmux panes and terminals

---

## Project Structure

```
.devcontainer/
├── Dockerfile
├── devcontainer.json
├── bootstrap.sh
```

---

## Requirements

- Docker Desktop with WSL 2 backend enabled
- SSH key at `~/.ssh/dotfiles_deploy_key`
- AWS credentials at `~/.aws/`
- Optional: `~/.dotfiles_token` fallback

---

## Manual Build (for testing)

```bash
docker build -t rust-dev-container .
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  -v ~/code/dotfiles:/root/code/dotfiles \
  -v ~/.ssh/dotfiles_deploy_key:/root/.ssh/dotfiles_deploy_key \
  rust-dev-container
```

---

## Troubleshooting

- If SSH fails: check `/root/.ssh/agent_env` or rerun `start_ssh_agent.sh`
- If RustRover doesn't detect the toolchain: verify the container is running
- If dotfiles don't sync: check SSH or fallback token config

---
