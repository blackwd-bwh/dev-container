#!/bin/bash
set -e

echo "🐳 Installing Docker..."

apt-get update && apt-get install -y docker.io && \
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "Docker CLI and daemon installed."
