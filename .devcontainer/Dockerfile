FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'source /root/.zshrc' >> /root/.zshrc && \
    echo '[[ -r /root/.p10k.zsh ]] && source /root/.p10k.zsh' >> /root/.zshrc && \
    ln -s /root/code/dotfiles/configs/.tmux.conf /root/.tmux.conf && \
    ln -s /root/code/dotfiles/configs/.gitconfig /root/.gitconfig

# Set working directory
WORKDIR /workspace

# Default shell
CMD ["sleep", "infinity"]
