# Setting Up DAO-Governance Repository

Follow these steps to create and push to your new GitHub repository.

## Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `DAO-Governance`
3. Description: `Diamond Standard DAO Governance and Signer Election System with Community Assessments`
4. Choose: Public or Private (your preference)
5. **DO NOT** initialize with README, .gitignore, or license (we have these already)
6. Click "Create repository"

## Step 2: Push Current Code to New Repository

```bash
cd /home/user/diamond-standard-tutorial

# Add the new remote (replace YOUR_USERNAME with your GitHub username)
git remote add dao-governance https://github.com/YOUR_USERNAME/DAO-Governance.git

# Push the current branch
git push dao-governance claude/explore-wsl2-alternative-Ia45V:main

# Or if you want to push main branch
git checkout main
git merge claude/explore-wsl2-alternative-Ia45V
git push dao-governance main
```

## Step 3: Set Default Repository

If you want to make this the primary repository:

```bash
# Remove old origin
git remote remove origin

# Rename dao-governance to origin
git remote rename dao-governance origin

# Set upstream
git branch --set-upstream-to=origin/main main
```

## Step 4: Verify

```bash
# Check remotes
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/DAO-Governance.git (fetch)
# origin  https://github.com/YOUR_USERNAME/DAO-Governance.git (push)
```

## Alternative: Start Fresh Repository

If you want a clean start:

```bash
# Navigate to parent directory
cd /home/user

# Create new directory
mkdir DAO-Governance
cd DAO-Governance

# Initialize git
git init

# Copy all files from old repo (except .git)
cp -r ../diamond-standard-tutorial/!(|.git) .

# Or use rsync
rsync -av --exclude='.git' ../diamond-standard-tutorial/ .

# Create .gitignore
cat > .gitignore << 'EOF'
node_modules/
artifacts/
cache/
.env
deployment.json
coverage/
typechain/
typechain-types/
*.log
.DS_Store
EOF

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: Diamond Standard DAO Governance System"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/DAO-Governance.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 5: Update Repository Description on GitHub

After pushing, go to your repository on GitHub and:

1. Click "About" (⚙️ gear icon)
2. Add description: "Diamond Standard DAO Governance and Signer Election System"
3. Add topics: `ethereum`, `solidity`, `diamond-standard`, `eip-2535`, `dao`, `governance`, `smart-contracts`
4. Save changes

## Step 6: Enable GitHub Pages (Optional)

If you want to host documentation:

1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: main, folder: / (root)
4. Save

Your documentation will be available at:
`https://YOUR_USERNAME.github.io/DAO-Governance/`

## Repository Structure

Your DAO-Governance repository will contain:

```
DAO-Governance/
├── contracts/              # All Diamond contracts
├── scripts/               # Deployment scripts
├── test/                  # Test suites
├── standalone/            # Standalone questionnaire (simpler version)
├── DEVELOPMENT_SETUP.md   # Setup guides
├── QUICK_REFERENCE.md     # Command cheatsheet
├── README.md              # Main documentation
├── package.json
└── hardhat.config.js
```

## Collaboration Setup

If colleagues will contribute:

```bash
# They should clone:
git clone https://github.com/YOUR_USERNAME/DAO-Governance.git
cd DAO-Governance

# Install dependencies
npm install

# Create their feature branch
git checkout -b feature/their-feature-name

# After changes
git add .
git commit -m "Description of changes"
git push origin feature/their-feature-name

# Then create Pull Request on GitHub
```

## Protecting Main Branch

On GitHub:
1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Check: "Require pull request reviews before merging"
4. Check: "Require status checks to pass before merging"
5. Save changes

This prevents direct pushes to main and requires PR reviews.

---

**Next:** See `standalone/README.md` for the simplified questionnaire you can deploy today!
