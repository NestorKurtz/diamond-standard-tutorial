#!/bin/bash

# Development Environment Setup Script
# Run this on a fresh WSL2 or Linux VPS installation

set -e  # Exit on error

echo "====================================="
echo "Development Environment Setup"
echo "====================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux/WSL2"
    exit 1
fi

print_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System packages updated"

print_info "Installing essential build tools..."
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    htop \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    tmux
print_success "Essential tools installed"

# Install Node.js via nvm
if ! command -v nvm &> /dev/null; then
    print_info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    print_success "nvm installed"
else
    print_success "nvm already installed"
fi

# Load nvm for this script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS
if ! command -v node &> /dev/null; then
    print_info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    print_success "Node.js $(node --version) installed"
else
    print_success "Node.js $(node --version) already installed"
fi

# Install yarn
if ! command -v yarn &> /dev/null; then
    print_info "Installing yarn..."
    npm install -g yarn
    print_success "yarn installed"
else
    print_success "yarn already installed"
fi

# Install Python and pip
print_info "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv
print_success "Python $(python3 --version) installed"

# Install Docker
if ! command -v docker &> /dev/null; then
    print_info "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed (logout and login for docker group to take effect)"
else
    print_success "Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_info "Installing Docker Compose..."
    sudo apt install -y docker-compose-plugin
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Install Foundry
if ! command -v forge &> /dev/null; then
    print_info "Installing Foundry (Solidity development framework)..."
    curl -L https://foundry.paradigm.xyz | bash

    # Add foundry to PATH for this session
    export PATH="$HOME/.foundry/bin:$PATH"

    # Run foundryup
    if [ -f "$HOME/.foundry/bin/foundryup" ]; then
        "$HOME/.foundry/bin/foundryup"
        print_success "Foundry installed"
    else
        print_error "Foundry installation may need manual completion. Run: foundryup"
    fi
else
    print_success "Foundry already installed"
fi

# Install Rust (optional, for Solana/Substrate development)
if ! command -v rustc &> /dev/null; then
    read -p "Install Rust? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        print_success "Rust installed"
    fi
else
    print_success "Rust already installed"
fi

# Install Go (optional)
if ! command -v go &> /dev/null; then
    read -p "Install Go? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing Go..."
        GO_VERSION="1.21.6"
        wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        rm "go${GO_VERSION}.linux-amd64.tar.gz"

        # Add to PATH
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go

        print_success "Go installed"
    fi
else
    print_success "Go already installed"
fi

# Set up useful aliases
print_info "Adding useful aliases to ~/.bashrc..."
cat >> ~/.bashrc << 'EOF'

# Development aliases (added by setup script)
alias ll='ls -alFh'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# Blockchain aliases
alias hh='npx hardhat'
alias ganache='ganache --deterministic --accounts 10'

# Navigation
alias projects='cd ~/projects'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF
print_success "Aliases added to ~/.bashrc"

# Create projects directory
if [ ! -d "$HOME/projects" ]; then
    mkdir -p "$HOME/projects"
    print_success "Created ~/projects directory"
else
    print_success "~/projects directory already exists"
fi

# Git configuration
print_info "Configuring Git..."
read -p "Enter your Git name (or press Enter to skip): " git_name
read -p "Enter your Git email (or press Enter to skip): " git_email

if [ ! -z "$git_name" ]; then
    git config --global user.name "$git_name"
fi

if [ ! -z "$git_email" ]; then
    git config --global user.email "$git_email"
fi

git config --global init.defaultBranch main
git config --global pull.rebase false
print_success "Git configured"

echo ""
echo "====================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "====================================="
echo ""
echo "Installed tools:"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - yarn: $(yarn --version)"
echo "  - Python: $(python3 --version | cut -d' ' -f2)"
echo "  - Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
echo "  - Git: $(git --version | cut -d' ' -f3)"

if command -v forge &> /dev/null; then
    echo "  - Foundry: $(forge --version | head -n1 | cut -d' ' -f2)"
fi

if command -v rustc &> /dev/null; then
    echo "  - Rust: $(rustc --version | cut -d' ' -f2)"
fi

if command -v go &> /dev/null; then
    echo "  - Go: $(go version | cut -d' ' -f3)"
fi

echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. If you installed Docker, logout and login for group changes"
echo "  3. Create a new project in ~/projects/"
echo "  4. Read DEVELOPMENT_SETUP.md for detailed guides"
echo ""
print_success "Happy coding!"
