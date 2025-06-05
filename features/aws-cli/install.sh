#!/bin/bash
set -e

echo "Installing AWS CLI v2..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

echo "✅ AWS CLI installed: $(aws --version)"
