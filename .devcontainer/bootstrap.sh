#!/bin/bash
set -euo pipefail

echo "🔧 Bootstrapping container environment..."

DOTFILES_DIR="/root/code/dotfiles"
TOKEN_FILE="/root/.dotfiles_token"
SSH_HOST="scm.bwhhg.io"

# 1. Prepare ~/.ssh
mkdir -p ~/.ssh

# 2. Check SSH agent
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  echo "⚠️  No SSH agent detected (SSH_AUTH_SOCK missing)."
else
  if ssh-add -l > /dev/null 2>&1; then
    echo "✅ SSH agent is available."
  else
    echo "⚠️  SSH agent detected but no keys loaded or inaccessible."
  fi
fi

# 3. SSH deploy key setup
if [ -f ~/.ssh/dotfiles_deploy_key ]; then
  echo "✅ Deploy key found at ~/.ssh/dotfiles_deploy_key"
  chmod 600 ~/.ssh/dotfiles_deploy_key
  if [ ! -f ~/.ssh/config ]; then
    echo "⚙️  Creating ~/.ssh/config"
    printf 'Host %s\n  HostName %s\n  User git\n  IdentityFile ~/.ssh/dotfiles_deploy_key\n  IdentitiesOnly yes\n' "$SSH_HOST" "$SSH_HOST" > ~/.ssh/config
  else
    echo "ℹ️  ~/.ssh/config already exists — leaving it unchanged."
  fi
  chmod 600 ~/.ssh/config
  ssh-keyscan "$SSH_HOST" >> ~/.ssh/known_hosts 2>/dev/null || true
  sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
else
  echo "⚠️  No SSH deploy key present — will fall back to HTTPS if needed."
fi

# 4. Git safe.directory
echo "📁 Attempting to configure Git safe.directory..."
if touch "$HOME/.gitconfig" 2>/dev/null; then
  git config --global --add safe.directory "$DOTFILES_DIR" && echo "✅ safe.directory set in user config"
else
  git config --system --add safe.directory "$DOTFILES_DIR" && echo "✅ safe.directory set in system config" || echo "❌ Failed to configure Git safe.directory"
fi

# 5. Dotfiles remote override logic
echo "🔁 Ensuring dotfiles repo uses correct remote..."
if nc -z -w2 "$SSH_HOST" 22; then
  echo "✅ SSH reachable — using SSH remote"
  git -C "$DOTFILES_DIR" remote set-url origin "git@$SSH_HOST:blackwd/dotfiles.git"
  git -C "$DOTFILES_DIR" pull origin master || echo "⚠️ SSH pull failed"
elif [ -f "$TOKEN_FILE" ]; then
  echo "🔐 SSH not reachable — falling back to HTTPS with token"
  echo "🔍 Found token file at $TOKEN_FILE"
  DOTFILES_TOKEN=$(<"$TOKEN_FILE")
  HTTPS_REMOTE="https://x-token-auth:${DOTFILES_TOKEN}@scm.bwhhg.io/scm/~blackwd/dotfiles.git"
  git -C "$DOTFILES_DIR" remote set-url origin "$HTTPS_REMOTE"
  GIT_TERMINAL_PROMPT=0 git -C "$DOTFILES_DIR" pull origin master || echo "⚠️ HTTPS pull failed"
else
  echo "❌ No deploy key or token available — skipping dotfiles pull"
  echo "📛 Debug: token file expected at $TOKEN_FILE but not found"
  ls -alh /root | grep dotfiles_token || echo "❗ .dotfiles_token not visible in /root"
fi

# 6. Run dotfiles setup
echo "⚙️  Running dotfiles setup..."
bash "$DOTFILES_DIR/dotfiles_setup.sh" || echo "⚠️ Dotfiles setup script failed"

# 7. Ensure Zsh config is symlinked properly
echo "🔗 Ensuring /root/.zshrc points to mounted dotfiles config..."
ln -sf "$DOTFILES_DIR/configs/.zshrc" /root/.zshrc

echo "✅ Bootstrap complete!"