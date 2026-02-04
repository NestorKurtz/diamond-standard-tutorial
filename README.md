# Diamond Standard Tutorial

Complete guide to EIP-2535 Diamond Standard - Learn how to build upgradeable smart contracts using the Diamond pattern.

## What is the Diamond Standard?

The Diamond Standard (EIP-2535) is a modular smart contract system that allows for:
- Unlimited contract size by breaking logic into facets
- Upgradeable contracts with fine-grained control
- Shared state across multiple facets
- Gas-efficient delegatecall-based architecture

## Getting Started

### Prerequisites

Before diving into Diamond Standard development, you'll need a proper development environment. We've created comprehensive guides for both local development (WSL2) and VPS server setup.

### Setup Guides

1. **[Development Setup Guide](./DEVELOPMENT_SETUP.md)** - Complete setup instructions for:
   - WSL2 on Windows (local development)
   - VPS server configuration (Linux)
   - All necessary blockchain development tools
   - Security best practices

2. **[Quick Reference](./QUICK_REFERENCE.md)** - Handy cheatsheet for:
   - Common commands (Git, npm, Hardhat, Foundry)
   - Blockchain-specific operations
   - Troubleshooting tips

3. **[Automated Setup Script](./scripts/setup-dev-env.sh)** - One-command installation:
   ```bash
   chmod +x scripts/setup-dev-env.sh
   ./scripts/setup-dev-env.sh
   ```

### Environment Configuration

Copy the environment template and configure your settings:

```bash
cp .env.example .env
# Edit .env with your API keys and RPC URLs
```

Never commit your `.env` file - it contains sensitive information!

## Project Structure

```
diamond-standard-tutorial/
├── contracts/              # Diamond contracts and facets (coming soon)
├── scripts/               # Deployment and utility scripts
│   └── setup-dev-env.sh  # Automated environment setup
├── test/                  # Test files (coming soon)
├── DEVELOPMENT_SETUP.md   # Comprehensive setup guide
├── QUICK_REFERENCE.md     # Command cheatsheet
├── .env.example          # Environment variables template
└── README.md             # This file
```

## Recommended Development Path

### For Local Development (Windows + WSL2)

1. Install WSL2 and Ubuntu
2. Run the setup script or follow the manual guide
3. Install VS Code with WSL extension
4. Clone this repository in WSL2 filesystem (`~/projects/`)
5. Start learning Diamond Standard patterns

### For VPS Server Development

1. Set up a secure VPS with SSH keys
2. Configure firewall (UFW)
3. Run the setup script
4. Use tmux for persistent sessions
5. Set up regular backups

## Why WSL2 Over PowerShell?

For blockchain development, WSL2 offers significant advantages:

- **Better Compatibility** - Native Linux tooling works seamlessly
- **Performance** - Faster npm installs and file operations
- **Ecosystem Alignment** - Most tutorials assume Unix environment
- **Real Bash Scripts** - Run scripts without modification
- **Docker Integration** - Better container performance

See [DEVELOPMENT_SETUP.md](./DEVELOPMENT_SETUP.md) for detailed comparison and setup instructions.

## Learning Resources

### Diamond Standard Specific
- [EIP-2535 Specification](https://eips.ethereum.org/EIPS/eip-2535)
- [Diamond Standard Reference Implementation](https://github.com/mudgen/diamond)
- [Nick Mudge's Blog](https://eip2535diamonds.substack.com/)

### General Solidity Development
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Ethereum Development Documentation](https://ethereum.org/en/developers/docs/)

## Featured Project: Diamond Governance Questionnaire

This repository includes a **complete Diamond Standard implementation** of a DAO governance and signer election system with community assessments!

### 🎉 World's First Diamond-Based Questionnaire System

The **Diamond Governance Questionnaire** is likely the first comprehensive assessment/questionnaire system built using the Diamond Standard (EIP-2535). It demonstrates the power of modular, upgradeable smart contracts.

### Key Features

**1. Candidate Nomination System**
- Community members can nominate candidates for signer positions
- Support for short statements (280 chars) or IPFS links for longer descriptions
- Nomination withdrawal capability
- Prevents self-nomination

**2. Community Assessment System**
- Unique 4-trait scoring system (100 points total per candidate):
  - Technical Competence (0-100)
  - Reliability & Commitment (0-100)
  - Communication & Transparency (0-100)
  - Alignment with DAO Values (0-100)
- Median-based score aggregation (resistant to outliers)
- Optional 69-character feedback
- Anonymous voting (wallet addresses not exposed)
- Real-time leaderboard

**3. Signer Availability Tracking**
- Status management (Active, OnLeave, Inactive, Removed)
- Real-time availability signaling
- Batch operations for efficiency

**4. Performance Monitoring**
- Automatic signature tracking
- Reliability score calculation (0-100)
- Performance leaderboards
- Underperformer identification

### Quick Start

```bash
# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm test

# Deploy to local network
npm run node
npm run deploy:local

# Deploy to Sepolia testnet
npm run deploy:sepolia
```

### Interacting with the System

```javascript
const diamond = await ethers.getContractAt("Diamond", diamondAddress);
const nomination = await ethers.getContractAt("NominationFacet", diamondAddress);
const assessment = await ethers.getContractAt("AssessmentFacet", diamondAddress);

// Open nomination phase
await nomination.setNominationPhaseStatus(true);

// Nominate candidate
await nomination.nominate(candidateAddress, "Excellent technical skills");

// Open assessment phase
await assessment.setAssessmentPhaseStatus(true);

// Assess candidate (4 trait scores totaling 100)
await assessment.assessCandidate(
  candidateAddress,
  [40, 30, 20, 10],
  "Strong technical background"
);

// View leaderboard
const [candidates, scores, totals] = await assessment.getLeaderboard();
console.log("Leaderboard:", candidates, scores, totals);
```

### Architecture

See [contracts/README.md](./contracts/README.md) for detailed architecture documentation.

### Gas Costs

Estimated costs on Sepolia:
- Nominate: ~50,000 gas (~$0.10)
- Assess: ~80,000 gas (~$0.15)
- Update status: ~30,000 gas (~$0.05)
- Record signature: ~40,000 gas (~$0.08)

## Next Steps

1. Set up your development environment using our guides
2. Understand the Diamond Standard architecture
3. Explore the Diamond Governance Questionnaire implementation
4. Deploy to testnet (Sepolia, Mumbai)
5. Customize facets for your use case
6. Learn gas optimization techniques

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter issues:
1. Check [DEVELOPMENT_SETUP.md](./DEVELOPMENT_SETUP.md) troubleshooting section
2. Review [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for common commands
3. Open an issue in this repository
4. Join blockchain development communities for help

---

Happy coding! Let's build amazing upgradeable smart contracts together.
