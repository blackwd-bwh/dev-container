FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system utilities and base dev tools
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
    ripgrep \
    fd-find \
    bat \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && apt-get clean

# Install Python 3.11 and pip
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Install uv (fast pip alternative)
RUN pip install uv

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install AWS CDK globally
RUN npm install -g aws-cdk

# Install Oh My Zsh and Powerlevel10k
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

# Copy dotfiles
COPY .tmux.conf /root/.tmux.conf
COPY .zshrc /root/.zshrc
COPY .p10k.zsh /root/.p10k.zsh

# Set working directory
WORKDIR /workspace