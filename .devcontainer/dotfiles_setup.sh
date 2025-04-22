#!/bin/bash
set -e

# Symlink dotfiles
echo "Setting up dotfiles..."
ln -sf /root/.dotfiles/.zshrc /root/.zshrc
ln -sf /root/.dotfiles/.p10k.zsh /root/.p10k.zsh
ln -sf /root/.dotfiles/.tmux.conf /root/.tmux.conf
ln -sf /root/.dotfiles/.gitconfig /root/.gitconfig
