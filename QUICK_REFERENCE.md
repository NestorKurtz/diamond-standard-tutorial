# Quick Reference Cheatsheet

Essential commands and workflows for blockchain development on WSL2/Linux.

## System Management

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Check disk space
df -h
du -sh ~/projects/*

# Monitor resources
htop

# Check running services
systemctl status <service-name>
```

## Git Commands

```bash
# Initialize and setup
git init
git remote add origin <url>

# Daily workflow
git status
git add .
git commit -m "message"
git push

# Branch management
git branch                          # List branches
git checkout -b feature/new         # Create and switch
git checkout main                   # Switch to main
git merge feature/new               # Merge branch
git branch -d feature/new           # Delete branch

# Undo changes
git restore <file>                  # Discard changes
git reset HEAD~1                    # Undo last commit (keep changes)
git reset --hard HEAD~1             # Undo last commit (discard changes)

# Stash changes
git stash                           # Save changes
git stash pop                       # Restore changes
git stash list                      # List stashes

# View history
git log --oneline --graph --decorate
git diff
```

## Node.js / npm / yarn

```bash
# Node version management
nvm list                            # List installed versions
nvm install --lts                   # Install latest LTS
nvm use 18                          # Switch to version 18
nvm alias default 18                # Set default version

# Package management
npm init -y                         # Initialize package.json
npm install <package>               # Install dependency
npm install -D <package>            # Install dev dependency
npm install -g <package>            # Install globally
npm update                          # Update packages
npm audit fix                       # Fix vulnerabilities

# Yarn equivalents
yarn init -y
yarn add <package>
yarn add -D <package>
yarn global add <package>
yarn upgrade
yarn audit

# Run scripts
npm run <script>
npm test
npm start
```

## Hardhat

```bash
# Initialize project
npx hardhat init

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
npx hardhat test --grep "TestName"

# Deploy
npx hardhat run scripts/deploy.js
npx hardhat run scripts/deploy.js --network sepolia

# Local node
npx hardhat node

# Console
npx hardhat console
npx hardhat console --network sepolia

# Verify contract
npx hardhat verify --network sepolia <address> <constructor-args>

# Clean
npx hardhat clean
```

## Foundry

```bash
# Initialize project
forge init my-project

# Build contracts
forge build

# Run tests
forge test
forge test -vvv                     # Verbose output
forge test --match-test testName    # Run specific test
forge test --gas-report             # Show gas usage

# Deploy
forge create src/Contract.sol:ContractName \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL

# Local node (Anvil)
anvil
anvil --fork-url $RPC_URL           # Fork mainnet

# Format code
forge fmt

# Gas snapshots
forge snapshot

# Coverage
forge coverage

# Cast (interact with contracts)
cast call <address> "balanceOf(address)" <holder-address>
cast send <address> "transfer(address,uint256)" <to> <amount> --private-key $PK
cast block latest
cast chain-id
```

## Docker

```bash
# Container management
docker ps                           # List running containers
docker ps -a                        # List all containers
docker stop <container>             # Stop container
docker rm <container>               # Remove container
docker logs <container>             # View logs
docker exec -it <container> bash    # Enter container

# Image management
docker images                       # List images
docker pull <image>                 # Pull image
docker rmi <image>                  # Remove image
docker build -t name:tag .          # Build image

# System cleanup
docker system prune                 # Remove unused data
docker system prune -a              # Remove all unused images

# Docker Compose
docker compose up                   # Start services
docker compose up -d                # Start in background
docker compose down                 # Stop services
docker compose logs -f              # Follow logs
docker compose ps                   # List services
```

## Environment Variables

```bash
# Set temporarily (current session)
export VARIABLE_NAME=value

# Set permanently (add to ~/.bashrc)
echo 'export VARIABLE_NAME=value' >> ~/.bashrc
source ~/.bashrc

# Use .env file (with dotenv)
echo "VARIABLE_NAME=value" >> .env

# Load .env in shell
export $(cat .env | xargs)

# View all variables
env
printenv
```

## Tmux (Terminal Multiplexer)

```bash
# Session management
tmux new -s session-name            # Create new session
tmux ls                             # List sessions
tmux attach -t session-name         # Attach to session
tmux kill-session -t session-name   # Kill session

# Inside tmux (Ctrl+b is prefix)
Ctrl+b c                            # Create new window
Ctrl+b n                            # Next window
Ctrl+b p                            # Previous window
Ctrl+b d                            # Detach from session
Ctrl+b [                            # Scroll mode (q to exit)
Ctrl+b %                            # Split vertically
Ctrl+b "                            # Split horizontally
Ctrl+b arrow                        # Navigate panes
```

## SSH

```bash
# Connect to server
ssh user@hostname
ssh user@hostname -p 2222           # Custom port
ssh -i ~/.ssh/key.pem user@host     # Use specific key

# Copy files
scp file.txt user@host:/path/       # Upload
scp user@host:/path/file.txt .      # Download
scp -r folder user@host:/path/      # Upload folder

# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Copy public key to server
ssh-copy-id user@host

# SSH config (~/.ssh/config)
Host myserver
    HostName 192.168.1.100
    User developer
    Port 2222
    IdentityFile ~/.ssh/mykey

# Then connect with: ssh myserver
```

## File Operations

```bash
# Navigation
cd /path/to/directory
cd ~                                # Home directory
cd -                                # Previous directory
pwd                                 # Current directory

# List files
ls -la                              # Detailed list
ls -lh                              # Human-readable sizes
ls -lt                              # Sort by modified time

# Create/Delete
mkdir -p path/to/dir                # Create directory (with parents)
touch file.txt                      # Create empty file
rm file.txt                         # Remove file
rm -rf directory                    # Remove directory (careful!)

# Copy/Move
cp source.txt dest.txt
cp -r source_dir dest_dir
mv old.txt new.txt

# Find files
find . -name "*.sol"                # Find by name
find . -type f -mtime -7            # Modified in last 7 days
find . -size +100M                  # Larger than 100MB

# Search in files
grep -r "pattern" .                 # Recursive search
grep -i "pattern" file.txt          # Case-insensitive
grep -n "pattern" file.txt          # Show line numbers

# File permissions
chmod +x script.sh                  # Make executable
chmod 644 file.txt                  # rw-r--r--
chmod 755 script.sh                 # rwxr-xr-x
chown user:group file.txt           # Change owner
```

## Network & Processes

```bash
# Network
ping google.com
curl https://api.example.com
wget https://example.com/file.zip
netstat -tuln                       # List open ports
ss -tuln                            # Modern alternative

# Process management
ps aux                              # List all processes
top                                 # Real-time processes
htop                                # Better top
kill <PID>                          # Kill process
killall <process-name>              # Kill by name
pkill -f "pattern"                  # Kill by pattern

# Background jobs
command &                           # Run in background
jobs                                # List background jobs
fg %1                               # Bring job 1 to foreground
bg %1                               # Resume job 1 in background
```

## Blockchain-Specific

```bash
# Check balances
cast balance <address>
cast balance <address> --rpc-url $RPC_URL

# Get block info
cast block latest
cast block 15000000

# Call contract (read)
cast call <address> "function()" --rpc-url $RPC_URL

# Send transaction (write)
cast send <address> "function(args)" --private-key $PK --rpc-url $RPC_URL

# Convert units
cast to-wei 1 ether
cast from-wei 1000000000000000000

# ABI encode/decode
cast abi-encode "function(uint256)" 42
cast abi-decode "function()(uint256)" <hex-data>

# Keccak hash
cast keccak "Transfer(address,address,uint256)"

# ENS
cast resolve-name vitalik.eth
```

## Useful One-Liners

```bash
# Disk usage sorted
du -sh * | sort -rh | head -10

# Find and delete node_modules
find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

# Count lines of code
find . -name "*.sol" | xargs wc -l

# Monitor file changes
watch -n 2 ls -lh file.txt

# Create backup with timestamp
cp file.txt "file_$(date +%Y%m%d_%H%M%S).txt"

# Find large files
find . -type f -size +100M -exec ls -lh {} \;

# Check port availability
nc -zv localhost 8545

# Generate random hex
openssl rand -hex 32

# Pretty print JSON
cat file.json | jq .
curl api.example.com | jq .

# Monitor logs in real-time
tail -f logfile.log
journalctl -fu service-name
```

## Gas Optimization Tips

```solidity
// Use calldata instead of memory for read-only function parameters
function process(uint[] calldata data) external { }

// Pack storage variables
uint128 a;  // 16 bytes
uint128 b;  // Same slot

// Use unchecked for safe operations
unchecked { counter++; }

// Cache array length
uint length = array.length;
for (uint i = 0; i < length;) {
    // ...
    unchecked { ++i; }
}

// Use custom errors instead of strings
error InsufficientBalance();
revert InsufficientBalance();

// Use events for data storage when possible
event DataStored(uint indexed id, bytes data);
```

## Environment Setup Verification

```bash
# Check all installations
node --version
npm --version
python3 --version
git --version
docker --version
forge --version

# Check loaded environment variables
echo $PRIVATE_KEY
echo $RPC_URL

# Verify network connectivity
cast chain-id --rpc-url $RPC_URL

# Test local node
anvil &
sleep 2
cast block latest --rpc-url http://localhost:8545
```

## Troubleshooting

```bash
# Clear npm cache
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Fix permissions
sudo chown -R $USER:$USER ~/projects

# Reset git repository
git reset --hard origin/main
git clean -fd

# View process using port
lsof -i :8545
sudo netstat -tulpn | grep :8545

# Fix WSL2 network
wsl --shutdown
# Then restart WSL

# Check system logs
sudo journalctl -xe
sudo tail -f /var/log/syslog
```

## Security Checklist

- [ ] Never commit `.env` files
- [ ] Use `.env.example` templates
- [ ] Keep dependencies updated
- [ ] Use hardware wallet for mainnet
- [ ] Test on testnets first
- [ ] Audit contracts before mainnet
- [ ] Use multi-sig for production
- [ ] Enable 2FA everywhere
- [ ] Regular backups
- [ ] Monitor contract events

---

Keep this cheatsheet handy for quick reference during development!
