#!/bin/bash
set -euo pipefail

echo "🔧 Bootstrapping container environment..."

# 1. Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Check if SSH agent is available
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  echo "⚠️  No SSH agent detected (SSH_AUTH_SOCK missing)."
  echo "⚠️  You might not be able to pull private Git repos inside container."
else
  if ssh-add -l > /dev/null 2>&1; then
    echo "✅ SSH agent is available."
  else
    echo "⚠️  SSH agent detected but no keys loaded or cannot access keys."
  fi
fi

# 2. Ensure SSH private key exists
if [ ! -f ~/.ssh/bitbucket ]; then
  echo "Warning: SSH private key ~/.ssh/bitbucket not found!"
  echo "Skipping SSH configuration."
else
  # 3. Write SSH config for scm.bwhhg.io if missing
  if [ ! -f ~/.ssh/config ]; then
    echo "⚙️ Creating new ~/.ssh/config"
    printf 'Host scm.bwhhg.io\nHostName scm.bwhhg.io\nUser git\nIdentityFile ~/.ssh/bitbucket\nIdentitiesOnly yes\n' > ~/.ssh/config
  else
    echo "~/.ssh/config already exists — leaving it unchanged."
  fi

  # 4. Secure permissions
  chmod 600 ~/.ssh/config ~/.ssh/bitbucket

  # 5. Add scm.bwhhg.io to known_hosts safely
  ssh-keyscan scm.bwhhg.io >> ~/.ssh/known_hosts || true
  sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
fi

# 6. Configure Git to trust mounted dotfiles directory
git config --global --add safe.directory /root/code/dotfiles

# 7. Run dotfiles setup
bash /root/.dotfiles/dotfiles_setup.sh

echo "✅ Bootstrap complete!"
