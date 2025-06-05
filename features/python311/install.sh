#!/bin/bash
set -e

echo "🐍 Installing Python 3.11 and tools..."

apt-get update && apt-get install -y \
  python3.11 python3.11-venv python3.11-distutils && \
  ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
  curl -sS https://bootstrap.pypa.io/get-pip.py | python3 && \
  pip install --no-cache-dir uv ipython && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

echo "Python 3.11 environment ready."
