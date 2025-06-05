#!/bin/bash
set -euo pipefail

echo "🔧 Linking dotfiles..."

# Ensure target directory exists
mkdir -p /root

# Shell config
echo 'source /root/.zshrc' >> /root/.zshrc || true
echo '[[ -r /root/.p10k.zsh ]] && source /root/.p10k.zsh' >> /root/.zshrc || true

# Symlink configs
ln -sf /root/code/dotfiles/configs/.tmux.conf /root/.tmux.conf
ln -sf /root/code/dotfiles/configs/.gitconfig /root/.gitconfig

echo "✅ Dotfiles linked"
