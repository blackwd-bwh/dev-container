#!/bin/bash
set -e

echo "📦 Installing AWS CDK..."

if ! command -v npm >/dev/null 2>&1; then
  echo "❌ npm not found. Please install Node.js first."
  exit 1
fi

npm install -g aws-cdk
echo "AWS CDK installed: $(cdk --version)"
