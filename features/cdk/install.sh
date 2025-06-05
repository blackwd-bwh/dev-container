#!/bin/bash
set -euo pipefail

echo "📦 Installing AWS CDK..."

if ! command -v npm >/dev/null 2>&1; then
  echo "📦 Node.js not found — installing Node.js 22.x..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y nodejs
fi

npm install -g aws-cdk

echo "✅ AWS CDK installed: $(command -v cdk)"
