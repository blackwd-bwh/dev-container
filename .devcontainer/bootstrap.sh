#!/bin/bash
set -euo pipefail

echo "🔧 Bootstrapping container environment..."

DOTFILES_DIR="/root/code/dotfiles"
TOKEN_FILE="/root/.dotfiles_token"
SSH_CONFIG="/root/.ssh/config"
GIT_REMOTE_SSH="git@dotfiles:~blackwd/dotfiles.git"
SSH_PORT=7999

# 1. Prepare fresh /root/.ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. Copy only necessary SSH keys if missing
echo "Copying SSH keys..."
[ ! -f /root/.ssh/dotfiles_deploy_key ] && cp /mnt/ssh/dotfiles_deploy_key /root/.ssh/dotfiles_deploy_key
[ ! -f /root/.ssh/bitbucket ] && cp /mnt/ssh/bitbucket /root/.ssh/bitbucket

# Fix ownership and permissions after copy
chown -R root:root ~/.ssh
chmod 600 ~/.ssh/*

# 3. Add dotfiles host alias if it's missing
if ! grep -q "Host dotfiles" "$SSH_CONFIG" 2>/dev/null; then
  echo "Writing SSH config entry for Host dotfiles"
  cat <<EOF >> "$SSH_CONFIG"

Host dotfiles
    HostName scm.bwhhg.io
    Port $SSH_PORT
    User git
    IdentityFile ~/.ssh/dotfiles_deploy_key
    IdentitiesOnly yes
EOF
else
  echo "Host dotfiles already present in SSH config"
fi

chmod 600 "$SSH_CONFIG"

# 4. Pre-load known_hosts to avoid SSH prompts
touch ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts
ssh-keyscan -p $SSH_PORT scm.bwhhg.io >> ~/.ssh/known_hosts 2>/dev/null || true
sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts

# 5. Configure Git safe.directory
echo "Configuring Git safe.directory..."
if touch "$HOME/.gitconfig" 2>/dev/null; then
  git config --global --add safe.directory "$DOTFILES_DIR"
  echo "safe.directory set in user config"
else
  git config --system --add safe.directory "$DOTFILES_DIR" || echo "Failed to configure Git safe.directory"
fi

# 6. Clone or update dotfiles
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "Cloning dotfiles repo..."
  if nc -z -w2 scm.bwhhg.io $SSH_PORT; then
    git clone "$GIT_REMOTE_SSH" "$DOTFILES_DIR" || echo "SSH clone failed"
  elif [ -f "$TOKEN_FILE" ]; then
    DOTFILES_TOKEN=$(<"$TOKEN_FILE")
    HTTPS_REMOTE="https://x-token-auth:${DOTFILES_TOKEN}@scm.bwhhg.io/scm/~blackwd/dotfiles.git"
    git clone "$HTTPS_REMOTE" "$DOTFILES_DIR" || echo "HTTPS clone failed"
  else
    echo "No deploy key or token available — skipping dotfiles clone"
  fi
else
  echo "Updating dotfiles..."
  git -C "$DOTFILES_DIR" remote set-url origin "$GIT_REMOTE_SSH"
  git -C "$DOTFILES_DIR" pull origin master || echo "Dotfiles update failed"
fi

# 7. Run dotfiles setup if available
echo "Running dotfiles setup..."
bash "$DOTFILES_DIR/dotfiles_setup.sh" || echo "Dotfiles setup script failed"

# 8. Link ZSH config
echo "Linking .zshrc from dotfiles..."
ln -sf "$DOTFILES_DIR/configs/.zshrc" /root/.zshrc

# 9. Start SSH agent and load keys
bash "$DOTFILES_DIR/scripts/start_ssh_agent.sh"

# 10. Optional: Unload the dotfiles deploy key
if ssh-add -l 2>/dev/null | grep -q "dotfiles_deploy_key"; then
  echo "Unloading dotfiles_deploy_key from SSH agent..."
  ssh-add -d ~/.ssh/dotfiles_deploy_key || echo "Failed to unload deploy key"
else
  echo "dotfiles_deploy_key not found in agent — nothing to unload"
fi

echo "✅ Bootstrap complete."
