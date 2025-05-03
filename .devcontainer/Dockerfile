FROM python:3.13-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install system utilities and development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    curl \
    wget \
    unzip \
    htop \
    jq \
    tmux \
    zsh \
    fonts-powerline \
    tree \
    bat \
    netcat-openbsd \
    build-essential \
    ca-certificates \
    gnupg \
    software-properties-common \
    openssh-client \
    && pip install --no-cache-dir uv ipython \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# Install AWS CDK globally
RUN npm install -g aws-cdk

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
