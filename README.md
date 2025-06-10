# Dev Container Environment

This project provides a ready-to-use development container for building and working with Python, Node.js, AWS CLI, CDK and Docker tooling.  
It includes a complete environment with Zsh, Powerlevel10k, tmux, and mounted personal dotfiles for a consistent development experience across machines.

Customizations are provided via an external dotfiles repository, ensuring consistent shell, Git, and terminal settings across environments.  
The container automatically installs required VS Code extensions, sets up Zsh with a custom Powerlevel10k configuration, and configures tmux with personalized keybindings and appearance settings to optimize terminal workflows.

This setup also includes robust SSH agent handling using a fixed socket path, enabling the SSH key to persist across tmux panes and terminals for the duration of the container session. 
The SSH agent is started manually with a custom script, and its socket and environment variables are saved and reused automatically.

---

## Features

- **Base**: **Python 3.13** (via official slim image)
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
  - Boto3 IDE
  - Indent Rainbow

---

## Requirements

Before using this Dev Container:

- Ensure Docker Desktop with WSL 2 backend is running (on Windows).
- Ensure your AWS credentials are located at `~/.aws/` inside WSL.
- Place your SSH deploy key at `~/.ssh/dotfiles_deploy_key` and unlock it when prompted.
- Optional: provide your HTTPS fallback token at `~/.dotfiles_token`.

No need to manually clone the dotfiles repository — it will be pulled automatically by the container's bootstrap process if not already present.

---

## Configuration

- **AWS Credentials**: Mounted from `~/.aws` → `/root/.aws`
- **Dotfiles**: Mounted from `~/code/dotfiles` → `/root/code/dotfiles`
- **SSH Key**: Mounted from `~/.ssh/dotfiles_deploy_key` → `/root/.ssh/dotfiles_deploy_key`
- **Zsh**: Configured with Oh My Zsh, Powerlevel10k theme, and git plugin
- **tmux**: Automatically starts on shell login
- **Git Config**: `.gitconfig` from dotfiles symlinked inside container

---

## Project Structure

```
.devcontainer/
├── Dockerfile
├── devcontainer.json
├── bootstrap.sh
```

---

## SSH Agent and Socket Handling

This dev container uses a persistent `ssh-agent` with a fixed socket path to ensure secure and seamless SSH key usage across all terminals and tmux sessions.

### How it works

- The agent is started in `start_ssh_agent.sh` using the socket:
  ```
  /root/.ssh/ssh-agent.sock
  ```
- The environment variables are written to:
  ```
  /root/.ssh/agent_env
  ```
- All new shells and tmux panes source that file to reuse the agent:
  ```bash
  source ~/.ssh/agent_env
  ```
- SSH keys are loaded once and available throughout the container session.

### Benefits

- You only enter your passphrase once per container session.
- SSH and Git commands can access your keys without re-prompting.
- Keys are never written to disk after loading — they remain in memory.
- tmux sessions, terminals, and scripts all use the same agent securely.

| Component                     | Purpose                                           |
|-------------------------------|---------------------------------------------------|
| `ssh-agent`                   | Holds SSH keys in memory                          |
| `/root/.ssh/ssh-agent.sock`   | Shared socket used by all sessions                |
| `/root/.ssh/agent_env`        | Saves agent socket path and process ID            |
| `start_ssh_agent.sh`          | Creates the socket, starts agent, and loads keys  |

---

## Startup Process

1. VS Code opens the folder and reads `.devcontainer/devcontainer.json`
2. Docker builds the image (via `Dockerfile`)
3. Container starts with all defined `mounts`
4. `bootstrap.sh` runs inside the container and:
   - Sets up `.ssh` and `known_hosts`
   - Clones or pulls dotfiles via SSH or HTTPS
   - Runs `dotfiles_setup.sh` inside the dotfiles repo
   - Symlinks `.zshrc`
   - Starts and initializes the SSH agent

---

## Usage (Manual)

To build and run the container manually:

```bash
docker build -t my-dev-container .
docker run -it --rm \
  -v ~/dev-container:/workspaces/dev-container \
  -v ~/.aws:/root/.aws \
  -v ~/code/dotfiles:/root/code/dotfiles \
  -v ~/.ssh/dotfiles_deploy_key:/root/.ssh/dotfiles_deploy_key \
  my-dev-container
```

---

## Usage (VS Code)

- Open the `dev-container/` folder in VS Code.
- Accept the prompt to "Reopen in Container."
- Your environment will be fully configured inside the container.

---

## Testing Git SSH Access

```bash
ssh -T git@scm.bwhhg.io -p 7999
```

---

## Troubleshooting

- If tmux doesn't start, check that `$TERM` is `screen-256color`
- If AWS CLI fails, verify `~/.aws` exists and contains valid credentials
- If dotfiles are not synced, verify that the key or token is correct and the repo is reachable
- Run `bash ~/code/dotfiles/scripts/start_ssh_agent.sh` manually if the key isn't loaded
- Run `source ~/.ssh/agent_env` in new tmux panes if needed

---

## Cleanup

To rebuild cleanly in VS Code:

```bash
Dev Containers: Rebuild and Reopen in Container
```

