#!/bin/bash
set -euo pipefail

echo "🔧 Bootstrapping container environment..."

# 1. Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# 2. Ensure SSH private deploy key exists
DEPLOY_KEY=~/.ssh/dotfiles_deploy_key
SSH_CONFIG=~/.ssh/config

if [ ! -f "$DEPLOY_KEY" ]; then
  echo "⚠️  SSH deploy key $DEPLOY_KEY not found!"
  echo "⚠️  Skipping SSH configuration — cannot pull private dotfiles."
else
  echo "✅ Deploy key found at $DEPLOY_KEY"

  # 3. Create SSH config if not exists
  if [ ! -f "$SSH_CONFIG" ]; then
    echo "⚙️  Creating new $SSH_CONFIG"
    printf 'Host scm.bwhhg.io\n  HostName scm.bwhhg.io\n  User git\n  IdentityFile %s\n  IdentitiesOnly yes\n' "$DEPLOY_KEY" > "$SSH_CONFIG"
  else
    echo "ℹ️  $SSH_CONFIG already exists — leaving it unchanged."
  fi

  # 4. Secure permissions
  chmod 600 "$DEPLOY_KEY" "$SSH_CONFIG"

  # 5. Add scm.bwhhg.io to known_hosts safely
  ssh-keyscan scm.bwhhg.io >> ~/.ssh/known_hosts 2>/dev/null || true
  sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
fi

# 6. Configure Git to trust mounted dotfiles directory
echo "📁 Attempting to configure Git safe.directory..."
if touch "$HOME/.gitconfig" 2>/dev/null; then
  git config --global --add safe.directory /root/code/dotfiles \
    && echo "✅ safe.directory set in user config"
else
  echo "⚠️  Could not write to $HOME/.gitconfig — trying system-level config instead..."
  git config --system --add safe.directory /root/code/dotfiles \
    && echo "✅ safe.directory set in system config" \
    || echo "❌ Failed to configure Git safe.directory at any level"
fi

# 7. Update remote to ensure correct SSH identity will be used
echo "🔁 Ensuring dotfiles repo uses correct SSH remote..."
if [ -d "/root/code/dotfiles/.git" ]; then
  git -C /root/code/dotfiles remote set-url origin git@scm.bwhhg.io:blackwd/dotfiles.git || echo "⚠️  Could not update remote URL"
fi

# 8. Pull latest dotfiles
if [ -d "/root/code/dotfiles/.git" ]; then
  echo "📥 Pulling latest updates from dotfiles repo..."
  git -C /root/code/dotfiles pull --ff-only || echo "⚠️  Failed to pull dotfiles — using existing copy"
else
  echo "⚠️  Dotfiles repo not found at /root/code/dotfiles — skipping pull"
fi

# 9. Run dotfiles setup script (symlinks configs, etc.)
echo "⚙️  Running dotfiles setup..."
bash /root/code/dotfiles/dotfiles_setup.sh || echo "⚠️  Dotfiles setup script failed"

# 10. Ensure the container's .zshrc points to mounted dotfiles config
echo "🔗 Ensuring /root/.zshrc points to mounted dotfiles config..."
ln -sf /root/code/dotfiles/configs/.zshrc /root/.zshrc

echo "✅ Bootstrap complete!"
