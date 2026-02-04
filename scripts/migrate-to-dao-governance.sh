#!/bin/bash

# Script to migrate Diamond Standard Tutorial to DAO-Governance repository
# This preserves all your work and creates a clean DAO-Governance repo

set -e

echo "========================================"
echo "DAO-Governance Repository Migration"
echo "========================================"
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo "❌ GitHub username required!"
    exit 1
fi

echo ""
echo "This script will:"
echo "  1. Create a new directory: ~/projects/DAO-Governance"
echo "  2. Copy all relevant files (excluding .git)"
echo "  3. Initialize a new git repository"
echo "  4. Set up remote to github.com/$GITHUB_USER/DAO-Governance"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration cancelled"
    exit 1
fi

# Create new directory
TARGET_DIR=~/projects/DAO-Governance

if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory $TARGET_DIR already exists!"
    read -p "Remove and continue? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TARGET_DIR"
    else
        echo "❌ Migration cancelled"
        exit 1
    fi
fi

mkdir -p ~/projects
cd ~/projects

echo ""
echo "📁 Creating DAO-Governance directory..."
mkdir DAO-Governance
cd DAO-Governance

echo "📋 Copying files..."

# Copy all files except .git
SOURCE_DIR=/home/user/diamond-standard-tutorial

cp -r "$SOURCE_DIR/contracts" .
cp -r "$SOURCE_DIR/scripts" .
cp -r "$SOURCE_DIR/test" .
cp -r "$SOURCE_DIR/standalone" .

cp "$SOURCE_DIR/README.md" .
cp "$SOURCE_DIR/LICENSE" . 2>/dev/null || true
cp "$SOURCE_DIR/DEVELOPMENT_SETUP.md" .
cp "$SOURCE_DIR/QUICK_REFERENCE.md" .
cp "$SOURCE_DIR/GITHUB_SETUP.md" .
cp "$SOURCE_DIR/.env.example" .
cp "$SOURCE_DIR/.gitignore" . 2>/dev/null || cp "$SOURCE_DIR/.gitignore" . 2>/dev/null || true
cp "$SOURCE_DIR/package.json" .
cp "$SOURCE_DIR/hardhat.config.js" .

# Create/update .gitignore
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
.nyc_output

# Hardhat
artifacts/
cache/
typechain/
typechain-types/

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Deployment
deployment.json
deployment-*.json

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Misc
.cache/
dist/
build/
EOF

echo "🔧 Initializing git..."
git init

echo "📝 Creating initial commit..."
git add .
git commit -m "Initial commit: Diamond Standard DAO Governance Questionnaire System

Complete implementation including:
- Diamond Standard contracts (EIP-2535)
- Standalone questionnaire contract (deploy today!)
- Comprehensive documentation
- Deployment scripts and tests
- Development environment guides

Features:
- 4-trait community assessment system
- Candidate nominations
- Signer availability tracking
- Performance monitoring
- Real-time leaderboards
"

echo "🔗 Adding GitHub remote..."
git remote add origin "https://github.com/$GITHUB_USER/DAO-Governance.git"

echo ""
echo "========================================"
echo "✅ Migration Complete!"
echo "========================================"
echo ""
echo "📂 New repository location: $TARGET_DIR"
echo ""
echo "📌 Next steps:"
echo ""
echo "1. Create repository on GitHub:"
echo "   → Go to https://github.com/new"
echo "   → Repository name: DAO-Governance"
echo "   → Description: Diamond Standard DAO Governance and Signer Election System"
echo "   → Make it Public or Private"
echo "   → DO NOT initialize with README"
echo "   → Click 'Create repository'"
echo ""
echo "2. Push to GitHub:"
echo "   cd $TARGET_DIR"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Done! Your repository will be at:"
echo "   https://github.com/$GITHUB_USER/DAO-Governance"
echo ""
echo "========================================"
echo ""
echo "🎉 You can now share the standalone questionnaire!"
echo "   Location: standalone/DAOQuestionnaire.sol"
echo "   Guide: standalone/QUICK_START.md"
echo ""
