FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------
# Core system utilities and development tools
# -----------------------------------------------------
#RUN apt-get update && apt-get install -y \
#    sudo git curl wget unzip htop jq tmux zsh \
#    fonts-powerline tree bat netcat \
#    build-essential ca-certificates gnupg \
#    lsb-release software-properties-common && \
#    apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------
# Optional: Docker CLI and Daemon
# -----------------------------------------------------
#RUN apt-get update && apt-get install -y docker.io && \
#    apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------
# Optional: Python 3.11 + pip + tools
# -----------------------------------------------------
#RUN apt-get update && apt-get install -y \
#    python3.11 python3.11-venv python3.11-distutils && \
#    ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
#    curl -sS https://bootstrap.pypa.io/get-pip.py | python3 && \
#    pip install --no-cache-dir uv ipython && \
#    apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------
# Install Node.js 22.x and npm
# -----------------------------------------------------
#RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
#    apt-get update && apt-get install -y nodejs && \
#    apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------
# Install AWS CLI v2
# -----------------------------------------------------
#RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
#    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# -----------------------------------------------------
# Install AWS CDK globally
# -----------------------------------------------------
#RUN npm install -g aws-cdk

# -----------------------------------------------------
# Shell Enhancements: Oh My Zsh + Powerlevel10k
# -----------------------------------------------------
#RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
#    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# -----------------------------------------------------
# Dotfiles setup (mounted via devcontainer.json)
# -----------------------------------------------------
RUN echo 'source /root/.zshrc' >> /root/.zshrc && \
    echo '[[ -r /root/.p10k.zsh ]] && source /root/.p10k.zsh' >> /root/.zshrc && \
    ln -s /root/code/dotfiles/configs/.tmux.conf /root/.tmux.conf && \
    ln -s /root/code/dotfiles/configs/.gitconfig /root/.gitconfig

# Set working directory
WORKDIR /workspace

# Default shell
CMD ["sleep", "infinity"]
