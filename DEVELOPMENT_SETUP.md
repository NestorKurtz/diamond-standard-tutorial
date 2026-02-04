# Complete Development Environment Setup Guide

This guide covers setting up a professional blockchain development environment on both WSL2 (local Windows machine) and VPS servers.

---

## Table of Contents
1. [WSL2 Setup (Local Windows Machine)](#wsl2-setup-local-windows-machine)
2. [VPS Server Setup (Linux)](#vps-server-setup-linux)
3. [Common Development Tools](#common-development-tools)
4. [Blockchain-Specific Tools](#blockchain-specific-tools)
5. [Best Practices](#best-practices)

---

## WSL2 Setup (Local Windows Machine)

### Step 1: Install WSL2

```powershell
# Run in PowerShell as Administrator
wsl --install
```

Or for manual installation:
```powershell
# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart your computer
# Then set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu (recommended)
wsl --install -d Ubuntu-22.04
```

### Step 2: Initial WSL2 Configuration

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential build tools
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
  lsb-release
```

### Step 3: Configure Git

```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Better diff and merge tools
git config --global merge.conflictstyle diff3
git config --global pull.rebase false

# Credential helper (optional - use Windows credentials)
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

### Step 4: VS Code Integration

1. Install VS Code on Windows
2. Install "WSL" extension in VS Code
3. Open WSL terminal and navigate to your project:
   ```bash
   cd ~/projects/your-project
   code .
   ```

### WSL2 Performance Tips

```bash
# Always work in Linux filesystem for better performance
# Good: /home/username/projects/
# Bad: /mnt/c/Users/username/projects/

# Create projects directory
mkdir -p ~/projects
cd ~/projects

# Optional: Create .wslconfig file in Windows to limit resources
# Location: C:\Users\YourUsername\.wslconfig
```

Example `.wslconfig` (Windows side):
```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
```

---

## VPS Server Setup (Linux)

### Step 1: Initial Server Security

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Create a new user (don't use root)
sudo adduser developer
sudo usermod -aG sudo developer

# Switch to new user
su - developer

# Set up SSH key authentication (more secure than password)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Paste your public key here
chmod 600 ~/.ssh/authorized_keys

# Configure SSH (on your server)
sudo nano /etc/ssh/sshd_config
# Recommended settings:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# Port 2222  # Optional: change from default 22

sudo systemctl restart sshd
```

### Step 2: Firewall Setup

```bash
# Install and configure UFW
sudo apt install -y ufw

# Allow SSH (use your custom port if changed)
sudo ufw allow 2222/tcp

# Allow HTTP/HTTPS (if running web services)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
sudo ufw status
```

### Step 3: Install Essential Tools

```bash
# Same as WSL2 setup
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
  lsb-release
```

### Step 4: Set Up Fail2Ban (Security)

```bash
# Protect against brute force attacks
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## Common Development Tools

### Node.js & npm (via nvm)

```bash
# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Reload shell configuration
source ~/.bashrc

# Install Node.js LTS
nvm install --lts
nvm use --lts

# Verify installation
node --version
npm --version

# Install yarn (optional but recommended)
npm install -g yarn
```

### Python

```bash
# Python 3 is usually pre-installed, but ensure latest
sudo apt install -y python3 python3-pip python3-venv

# Verify
python3 --version
pip3 --version
```

### Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (no sudo needed for docker commands)
sudo usermod -aG docker $USER

# Log out and back in, then verify
docker --version

# Install Docker Compose
sudo apt install -y docker-compose-plugin

# Verify
docker compose version
```

### Rust (for Solana, Substrate, etc.)

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Reload environment
source ~/.cargo/env

# Verify
rustc --version
cargo --version
```

### Go (for various blockchain tools)

```bash
# Download and install Go
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz

# Add to PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
source ~/.bashrc

# Verify
go version
```

---

## Blockchain-Specific Tools

### Foundry (Recommended for Solidity)

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify
forge --version
cast --version
anvil --version
```

### Hardhat

```bash
# Install globally (or per-project)
npm install -g hardhat

# Or for this project
npm install --save-dev hardhat
```

### Solidity Compiler

```bash
# Install via npm
npm install -g solc

# Or via binaries
sudo add-apt-repository ppa:ethereum/ethereum
sudo apt update
sudo apt install -y solc

# Verify
solc --version
```

### Ganache (Local Blockchain)

```bash
npm install -g ganache
```

### Web3 Libraries

```bash
# Ethers.js (recommended)
npm install ethers

# Web3.js (alternative)
npm install web3
```

### IPFS

```bash
# Download and install IPFS
wget https://dist.ipfs.tech/kubo/v0.24.0/kubo_v0.24.0_linux-amd64.tar.gz
tar -xvzf kubo_v0.24.0_linux-amd64.tar.gz
cd kubo
sudo bash install.sh

# Initialize IPFS
ipfs init

# Verify
ipfs --version
```

---

## Best Practices

### Environment Variables

```bash
# Create .env file template
cat > .env.example << 'EOF'
# Blockchain RPC URLs
ETHEREUM_RPC_URL=
POLYGON_RPC_URL=
ARBITRUM_RPC_URL=

# API Keys
ETHERSCAN_API_KEY=
ALCHEMY_API_KEY=
INFURA_PROJECT_ID=

# Private Keys (NEVER commit real keys!)
PRIVATE_KEY=
DEPLOYER_PRIVATE_KEY=

# Other
NETWORK=localhost
EOF

# Add .env to .gitignore
echo ".env" >> .gitignore
```

### Shell Configuration

```bash
# Add useful aliases to ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# Aliases
alias ll='ls -alFh'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# Blockchain aliases
alias hh='npx hardhat'
alias ganache='ganache --deterministic --accounts 10'
alias anvil-fork='anvil --fork-url $ETHEREUM_RPC_URL'

# Navigation
alias projects='cd ~/projects'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF

source ~/.bashrc
```

### Project Structure

```bash
# Recommended structure for blockchain projects
project/
├── contracts/          # Solidity smart contracts
├── scripts/            # Deployment and utility scripts
├── test/              # Test files
├── artifacts/         # Compiled contracts (gitignored)
├── cache/             # Build cache (gitignored)
├── node_modules/      # Dependencies (gitignored)
├── .env               # Environment variables (gitignored)
├── .env.example       # Template for env vars
├── .gitignore
├── hardhat.config.js  # Hardhat configuration
├── package.json
└── README.md
```

### Git Workflow

```bash
# Initialize git in project
git init
git add .
git commit -m "Initial commit"

# Connect to remote
git remote add origin https://github.com/username/repo.git
git push -u origin main

# Branch workflow
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "Add new feature"
git push -u origin feature/new-feature
```

### Security Checklist

- [ ] Never commit private keys or secrets
- [ ] Use environment variables for sensitive data
- [ ] Keep dependencies updated (`npm audit`, `npm update`)
- [ ] Use SSH keys for server access
- [ ] Enable 2FA on GitHub/GitLab
- [ ] Regular backups of important data
- [ ] Use hardware wallet for mainnet deployments
- [ ] Test thoroughly on testnets before mainnet
- [ ] Use `.gitignore` to exclude sensitive files

### VPS-Specific Tips

```bash
# Set up automatic security updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Monitor system resources
htop

# Check disk usage
df -h
du -sh ~/projects/*

# Monitor logs
sudo tail -f /var/log/syslog

# Set up tmux for persistent sessions
sudo apt install -y tmux
tmux new -s dev
# Detach: Ctrl+b, then d
# Reattach: tmux attach -t dev
```

### Backup Strategy

```bash
# Create backup script
cat > ~/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/backups
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup projects
tar -czf $BACKUP_DIR/projects_$DATE.tar.gz ~/projects

# Keep only last 7 days of backups
find $BACKUP_DIR -name "projects_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/projects_$DATE.tar.gz"
EOF

chmod +x ~/backup.sh

# Run backup manually
~/backup.sh

# Or set up cron job (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * ~/backup.sh") | crontab -
```

---

## Testing Your Setup

### Quick Test Commands

```bash
# Node.js
node -e "console.log('Node.js works!')"

# npm
npm --version

# Git
git --version

# Python
python3 --version

# Docker
docker run hello-world

# Foundry (if installed)
forge --version

# Check all Node global packages
npm list -g --depth=0
```

### Test Hardhat Project

```bash
mkdir -p ~/projects/test-hardhat
cd ~/projects/test-hardhat
npm init -y
npm install --save-dev hardhat
npx hardhat init
# Select "Create a JavaScript project"
npx hardhat test
```

### Test Foundry Project

```bash
mkdir -p ~/projects/test-foundry
cd ~/projects/test-foundry
forge init
forge test
```

---

## Troubleshooting

### WSL2 Issues

**Slow file system performance:**
- Ensure you're working in Linux filesystem (`~/`) not Windows (`/mnt/c/`)

**Network issues:**
```bash
# Reset WSL network
wsl --shutdown
# Restart WSL
```

**Out of memory:**
- Create or edit `.wslconfig` in Windows user directory to limit RAM

### VPS Issues

**Can't connect via SSH:**
- Check firewall rules: `sudo ufw status`
- Verify SSH is running: `sudo systemctl status sshd`
- Check SSH port is open on provider's firewall

**Disk space full:**
```bash
# Find large files/directories
du -h ~ | sort -rh | head -20

# Clean npm cache
npm cache clean --force

# Clean Docker
docker system prune -a
```

---

## Next Steps

1. Set up your preferred development environment (WSL2 or VPS)
2. Install the tools you need for your specific projects
3. Clone this repository and start learning Diamond Standard
4. Practice deploying to testnets (Sepolia, Mumbai, etc.)
5. Join blockchain development communities (Discord, Reddit, forums)

---

## Useful Resources

- [Ethereum Development Documentation](https://ethereum.org/en/developers/docs/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)

---

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Search for error messages online
3. Ask in blockchain development communities
4. Open an issue in this repository

Happy coding!
