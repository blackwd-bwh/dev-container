FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:$PATH"

# Install system utilities and development tools
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    wget \
    unzip \
    htop \
    jq \
    tmux \
    docker.io \
    zsh \
    fonts-powerline \
    tree \
    bat \
    netcat \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && apt-get clean

# Install Rust using rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup component add rustfmt clippy

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# Install Oh My Zsh and Powerlevel10k
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Set up dotfiles mounting (assumes /root/.dotfiles is mounted by devcontainer.json)
RUN echo 'source /root/.zshrc' >> /root/.zshrc && \
    echo '[[ -r /root/.p10k.zsh ]] && source /root/.p10k.zsh' >> /root/.zshrc && \
    ln -s /root/code/dotfiles/configs/.tmux.conf /root/.tmux.conf && \
    ln -s /root/code/dotfiles/configs/.gitconfig /root/.gitconfig

# Set working directory
WORKDIR /workspace

# Default shell
CMD ["sleep", "infinity"]
