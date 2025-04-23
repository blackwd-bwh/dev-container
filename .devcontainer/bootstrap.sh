#!/bin/bash
set -euo pipefail

echo "🔧 Bootstrapping container environment..."

DOTFILES_DIR="/root/code/dotfiles"
TOKEN_FILE="/root/.dotfiles_token"
SSH_KEY="/root/.ssh/dotfiles_deploy_key"
SSH_CONFIG="/root/.ssh/config"
SSH_PORT=7999
GIT_REMOTE_SSH="ssh://git@scm.bwhhg.io:${SSH_PORT}/~blackwd/dotfiles.git"

# 1. Create .ssh directory if it doesn't exist
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

# 3. Set up SSH config if key is available
if [ -f "$SSH_KEY" ]; then
  echo "✅ Deploy key found at $SSH_KEY"
  chmod 600 "$SSH_KEY"

  # Inject or ensure proper config
  if ! grep -q "scm.bwhhg.io" "$SSH_CONFIG" 2>/dev/null; then
    echo "⚙️  Writing ~/.ssh/config for scm.bwhhg.io..."
    cat <<EOF > "$SSH_CONFIG"
Host scm.bwhhg.io
    HostName scm.bwhhg.io
    Port $SSH_PORT
    User git
    IdentityFile $SSH_KEY
    IdentitiesOnly yes
EOF
  else
    echo "ℹ️  ~/.ssh/config already exists — leaving it unchanged."
  fi

  chmod 600 "$SSH_CONFIG"
  ssh-keyscan -p $SSH_PORT scm.bwhhg.io >> ~/.ssh/known_hosts 2>/dev/null || true
  sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
else
  echo "⚠️  No SSH deploy key present — will fall back to HTTPS if needed."
fi

# 4. Configure Git safe.directory
echo "📁 Configuring Git safe.directory..."
if touch "$HOME/.gitconfig" 2>/dev/null; then
  git config --global --add safe.directory "$DOTFILES_DIR"
  echo "✅ safe.directory set in user config"
else
  git config --system --add safe.directory "$DOTFILES_DIR" && echo "✅ safe.directory set in system config" || echo "❌ Failed to configure Git safe.directory"
fi

# 5. Set correct remote and pull dotfiles
echo "🔁 Ensuring dotfiles repo uses correct remote..."
git -C "$DOTFILES_DIR" remote set-url origin "$GIT_REMOTE_SSH"

if nc -z -w2 scm.bwhhg.io $SSH_PORT; then
  echo "🔐 SSH reachable on port $SSH_PORT — attempting to pull"
  GIT_SSH_COMMAND="ssh -p $SSH_PORT -i $SSH_KEY" git -C "$DOTFILES_DIR" pull origin master || echo "⚠️ SSH pull failed"
elif [ -f "$TOKEN_FILE" ]; then
  echo "🔐 SSH not reachable — falling back to HTTPS with token"
  echo "🔍 Found token file at $TOKEN_FILE"
  DOTFILES_TOKEN=$(<"$TOKEN_FILE")
  HTTPS_REMOTE="https://x-token-auth:${DOTFILES_TOKEN}@scm.bwhhg.io/scm/~blackwd/dotfiles.git"
  git -C "$DOTFILES_DIR" remote set-url origin "$HTTPS_REMOTE"
  GIT_TERMINAL_PROMPT=0 git -C "$DOTFILES_DIR" pull origin master || echo "⚠️ HTTPS pull failed"
else
  echo "❌ No deploy key or token available — skipping dotfiles pull"
fi

# 6. Run dotfiles setup script
echo "⚙️  Running dotfiles setup..."
bash "$DOTFILES_DIR/dotfiles_setup.sh" || echo "⚠️ Dotfiles setup script failed"

# 7. Ensure .zshrc is linked to mounted config
echo "🔗 Ensuring /root/.zshrc points to mounted dotfiles config..."
ln -sf "$DOTFILES_DIR/configs/.zshrc" /root/.zshrc

echo "✅ Bootstrap complete!"
