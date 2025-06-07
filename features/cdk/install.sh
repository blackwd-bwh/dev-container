#!/bin/bash
set -euo pipefail

echo "📦 Installing AWS CDK..."

npm install -g aws-cdk

echo "✅ AWS CDK installed: $(command -v cdk)"
