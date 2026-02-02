# CLAUDE.md

## Project Overview

**diamond-standard-tutorial** is a complete guide to EIP-2535 (Diamond Standard) for Ethereum smart contracts. The project is licensed under MIT and authored by Nestor.

**Current state:** Newly initialized repository with foundational files only (README, LICENSE, .gitignore). No source code, contracts, or build tooling has been added yet.

## Repository Structure

```
diamond-standard-tutorial/
├── .gitignore          # Node.js-oriented ignore rules (npm, yarn, pnpm)
├── LICENSE             # MIT License
├── README.md           # Project title and description
└── CLAUDE.md           # This file
```

## EIP-2535 Diamond Standard Context

This project is a tutorial for the Diamond Standard, a Solidity smart contract architecture pattern. Key concepts AI assistants should understand:

- **Diamond:** A proxy contract that delegates calls to multiple implementation contracts (facets)
- **Facets:** Individual contracts containing specific functionality, registered with the Diamond
- **DiamondCut:** The mechanism for adding, replacing, or removing facets from a Diamond
- **DiamondLoupe:** Introspection functions to query which facets and functions a Diamond supports
- **AppStorage / Diamond Storage:** Storage patterns that avoid slot collisions across facets
- **Reference:** [EIP-2535 specification](https://eips.ethereum.org/EIPS/eip-2535)

## Intended Tech Stack (inferred from .gitignore)

- **Language:** Solidity (smart contracts), TypeScript/JavaScript (scripts, tests, tooling)
- **Package manager:** npm, yarn, or pnpm (all supported by .gitignore)
- **Expected frameworks:** Hardhat or Foundry for smart contract development
- **Node.js** ecosystem for scripting, testing, and deployment
- **Environment variables:** `.env` files gitignored; `.env.example` is preserved

## Development Guidelines

### Setting Up the Project

When initializing tooling for this project, prefer:
1. **Hardhat** with TypeScript for Solidity development (most common for Diamond tutorials)
2. Standard directory layout: `contracts/`, `scripts/`, `test/`, `deploy/`
3. Diamond-specific contract structure:
   - `contracts/Diamond.sol` - main proxy contract
   - `contracts/facets/` - individual facet contracts
   - `contracts/interfaces/` - interface definitions (IDiamondCut, IDiamondLoupe, etc.)
   - `contracts/libraries/` - shared libraries (LibDiamond, AppStorage)
   - `contracts/upgradeInitializers/` - initialization contracts for upgrades

### Code Conventions

- **Solidity:** Follow the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- **Solidity version:** Use a consistent pragma (e.g., `^0.8.0` or higher)
- **TypeScript:** Use strict mode; prefer `const` over `let`
- **Testing:** Write tests for every facet; test diamond cuts (add, replace, remove)
- **NatSpec:** Use NatSpec comments on all public/external Solidity functions
- **Named imports:** Prefer named imports over wildcard imports in Solidity

### File Naming

- Solidity contracts: PascalCase (e.g., `DiamondCutFacet.sol`)
- TypeScript/JavaScript files: camelCase (e.g., `deployDiamond.ts`)
- Test files: Match the contract name with `.test.ts` suffix (e.g., `DiamondCutFacet.test.ts`)

### Security

- Never commit `.env` files or private keys
- Use `.env.example` to document required environment variables
- Validate all diamond cut operations in tests
- Be aware of storage collision risks when adding or modifying facets
- Follow the checks-effects-interactions pattern in Solidity

## Build & Test Commands

No build system is configured yet. When one is added, expected commands will follow standard Hardhat conventions:

```bash
npx hardhat compile        # Compile contracts
npx hardhat test           # Run test suite
npx hardhat deploy         # Deploy contracts (if hardhat-deploy plugin is used)
npx hardhat node           # Start local node
```

## Git Workflow

- **Main branch:** contains the initial commit
- Develop on feature branches
- Write descriptive commit messages focused on "why" not "what"
- Keep commits atomic and focused on single changes

## Notes for AI Assistants

1. This repo is in its initial state -- there is no source code to read yet. When asked to build features, scaffold the appropriate project structure first.
2. The Diamond Standard is a specific EIP (2535). Do not confuse it with other proxy patterns (EIP-1967 transparent proxy, UUPS, etc.). Diamond is multi-facet, not single-implementation.
3. When generating Solidity code, always use the diamond storage pattern (not inherited storage) to avoid slot collisions between facets.
4. Reference implementations exist at [mudgen/diamond-3-hardhat](https://github.com/mudgen/diamond-3-hardhat) -- this is the canonical reference by the EIP author (Nick Mudge).
5. The `.gitignore` is comprehensive for Node.js projects; no additional ignore rules should be needed for standard development.
