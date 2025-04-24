#!/bin/bash
set -euo pipefail

echo "Bootstrapping container environment..."

# Define key paths and settings
DOTFILES_DIR="/root/code/dotfiles"
TOKEN_FILE="/root/.dotfiles_token"
SSH_KEY="/root/.ssh/dotfiles_deploy_key"
SSH_CONFIG="/root/.ssh/config"
SSH_PORT=7999
GIT_REMOTE_SSH="ssh://git@scm.bwhhg.io:${SSH_PORT}/~blackwd/dotfiles.git"

# 1. Ensure the ~/.ssh directory exists with correct permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. Create or reset known_hosts to avoid interactive prompts
touch ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts

# 3. Write SSH config for the deploy key if it exists
if [ -f "$SSH_KEY" ]; then
  echo "Deploy key found at $SSH_KEY"
  chmod 600 "$SSH_KEY"

  # Only write config if it doesn't already exist for the host
  if ! grep -q "scm.bwhhg.io" "$SSH_CONFIG" 2>/dev/null; then
    echo "Writing SSH config for scm.bwhhg.io"
    cat <<EOF > "$SSH_CONFIG"
Host scm.bwhhg.io
    HostName scm.bwhhg.io
    Port $SSH_PORT
    User git
    IdentityFile $SSH_KEY
    IdentitiesOnly yes
EOF
  else
    echo "SSH config already present."
  fi

  chmod 600 "$SSH_CONFIG"

  # Add scm.bwhhg.io to known_hosts to avoid prompt on first SSH use
  ssh-keyscan -p $SSH_PORT scm.bwhhg.io >> ~/.ssh/known_hosts 2>/dev/null || true
  sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
else
  echo "No SSH deploy key present — will fall back to HTTPS if needed."
fi

# 4. Configure Git safe.directory to avoid ownership warnings in Git 2.35+
echo "Configuring Git safe.directory..."
if touch "$HOME/.gitconfig" 2>/dev/null; then
  git config --global --add safe.directory "$DOTFILES_DIR"
  echo "safe.directory set in user config"
else
  git config --system --add safe.directory "$DOTFILES_DIR" && echo "safe.directory set in system config" || echo "Failed to configure Git safe.directory"
fi

# 5. Update the remote and sync the dotfiles repository
echo "Syncing dotfiles from remote..."
git -C "$DOTFILES_DIR" remote set-url origin "$GIT_REMOTE_SSH"

# Prefer SSH if reachable, fall back to HTTPS with token
if nc -z -w2 scm.bwhhg.io $SSH_PORT; then
  echo "SSH reachable — pulling via SSH..."
  GIT_SSH_COMMAND="ssh -p $SSH_PORT -i $SSH_KEY" git -C "$DOTFILES_DIR" pull origin master || echo "SSH pull failed"
elif [ -f "$TOKEN_FILE" ]; then
  echo "SSH not reachable — falling back to HTTPS with token"
  DOTFILES_TOKEN=$(<"$TOKEN_FILE")
  HTTPS_REMOTE="https://x-token-auth:${DOTFILES_TOKEN}@scm.bwhhg.io/scm/~blackwd/dotfiles.git"
  git -C "$DOTFILES_DIR" remote set-url origin "$HTTPS_REMOTE"
  GIT_TERMINAL_PROMPT=0 git -C "$DOTFILES_DIR" pull origin master || echo "HTTPS pull failed"
else
  echo "No deploy key or token available — skipping dotfiles pull"
fi

# 6. Run any dotfiles-specific setup script
echo "Running dotfiles setup..."
bash "$DOTFILES_DIR/dotfiles_setup.sh" || echo "Dotfiles setup script failed"

# 7. Link .zshrc from the dotfiles mount
echo "Linking .zshrc to mounted config..."
ln -sf "$DOTFILES_DIR/configs/.zshrc" /root/.zshrc

# 8. Start SSH agent and load key if needed
bash "$DOTFILES_DIR/scripts/start_ssh_agent.sh"

echo "Bootstrap complete."
