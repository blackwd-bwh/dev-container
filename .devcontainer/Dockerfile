FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3 \
    && pip install uv \
    && apt-get clean

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && apt-get install -y nodejs

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# Install AWS CDK globally
RUN npm install -g aws-cdk

# Install Oh My Zsh and Powerlevel10k
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Set up dotfiles mounting (assumes /root/.dotfiles is mounted by devcontainer.json)
RUN echo 'source /root/.dotfiles/.zshrc' >> /root/.zshrc && \
    echo '[[ -r /root/.dotfiles/.p10k.zsh ]] && source /root/.dotfiles/.p10k.zsh' >> /root/.zshrc && \
    ln -s /root/.dotfiles/.tmux.conf /root/.tmux.conf && \
    ln -s /root/.dotfiles/.gitconfig /root/.gitconfig

# Set working directory
WORKDIR /workspace

# Default shell
#CMD ["zsh", "-i"]
CMD ["bash", "-c", "while true; do sleep 1000; done"]

