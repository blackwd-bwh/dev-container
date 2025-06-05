#!/bin/bash
set -euo pipefail

echo "=== dotfiles-setup feature running ===" > /tmp/feature-debug.log
echo "🔧 Linking dotfiles..."

DOTFILES_DIR="/root/code/dotfiles/configs"

# Create target dirs if needed
mkdir -p /root

# Ensure lines are not duplicated
ZSHRC="/root/.zshrc"

if ! grep -qF 'source /root/.zshrc' "$ZSHRC" 2>/dev/null; then
  echo 'source /root/.zshrc' >> "$ZSHRC"
fi

if ! grep -qF 'source /root/.p10k.zsh' "$ZSHRC" 2>/dev/null; then
  echo '[[ -r /root/.p10k.zsh ]] && source /root/.p10k.zsh' >> "$ZSHRC"
fi

# Symlink configs safely
ln -sf "$DOTFILES_DIR/.tmux.conf" /root/.tmux.conf
ln -sf "$DOTFILES_DIR/.gitconfig" /root/.gitconfig

echo "✅ Dotfiles linked"
