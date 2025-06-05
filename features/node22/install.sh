#!/bin/bash
set -euo pipefail

echo "🔧 Installing Node.js 22.x from NodeSource..."

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get update
apt-get install -y nodejs
apt-get clean
rm -rf /var/lib/apt/lists/*

