#!/bin/bash
set -euo pipefail

echo "🔧 Installing shared development tools..."

# Make sure we’re on a Debian-based image
if ! command -v apt-get >/dev/null; then
  echo "❌ This feature only supports Debian-based images (apt-get required)."
  exit 1
fi

apt-get update

# Core packages
DEBIAN_PACKAGES=(
  sudo git curl wget unzip htop jq tmux zsh
  fonts-powerline tree bat build-essential
  ca-certificates gnupg lsb-release software-properties-common
)

# Install netcat-openbsd if available
if apt-cache show netcat-openbsd >/dev/null 2>&1; then
  DEBIAN_PACKAGES+=("netcat-openbsd")
else
  echo "⚠️ netcat-openbsd not available in this image. Skipping."
fi

# Install all packages
apt-get install -y "${DEBIAN_PACKAGES[@]}"

# Zsh + Powerlevel10k handling
if [[ "${_BUILD_ARG_FORCE_REINSTALL_ZSH:-false}" == "true" ]]; then
  echo "🔁 Forcing reinstallation of Oh My Zsh and Powerlevel10k"
  rm -rf "$HOME/.oh-my-zsh" "$HOME/.zshrc" "$HOME/.p10k.zsh"
fi

# Oh My Zsh install
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🎉 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh already installed — skipping."
fi

# Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "🎨 Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "✅ Powerlevel10k already present — skipping."
fi

# Ensure .p10k.zsh is sourced from .zshrc
ZSHRC="$HOME/.zshrc"
P10K_LINE='[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh'

if ! grep -Fxq "$P10K_LINE" "$ZSHRC"; then
  echo "💡 Appending Powerlevel10k config to .zshrc"
  echo "$P10K_LINE" >> "$ZSHRC"
else
  echo "✅ .p10k.zsh sourcing already present in .zshrc"
fi

# Clean up APT cache to reduce image size
echo "🧼 Cleaning up apt cache..."
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "✅ Shared dev setup complete."
