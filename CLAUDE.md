# CLAUDE.md

## Project Overview

**diamond-standard-tutorial** is a tutorial and reference implementation for EIP-2535 (the Diamond Standard), an Ethereum smart contract upgradeability pattern. The project is licensed under MIT.

## Current State

This repository is in its initial skeleton phase. It contains only foundational files:

```
diamond-standard-tutorial/
├── .gitignore       # Node.js/JavaScript template
├── LICENSE          # MIT License
├── README.md        # Minimal project description
└── CLAUDE.md        # This file
```

No source code, smart contracts, tests, configuration files, or dependencies have been added yet.

## Intended Technology Stack

Based on project context and the .gitignore configuration:

- **Language**: Solidity (smart contracts), JavaScript/TypeScript (scripts, tests, deployment)
- **Package manager**: npm or yarn
- **Smart contract framework**: Hardhat or Foundry (to be configured)
- **Testing**: Hardhat test runner (Mocha/Chai) or Foundry's forge test
- **Network**: Ethereum-compatible blockchains

## EIP-2535 Diamond Standard Concepts

The Diamond Standard defines a modular smart contract architecture:

- **Diamond**: The main proxy contract that delegates calls to facets
- **Facets**: Implementation contracts containing business logic
- **DiamondCut**: The mechanism for adding, replacing, or removing facets
- **DiamondLoupe**: Introspection functions to inspect which facets and functions exist
- **AppStorage**: A shared storage pattern used across facets to avoid storage collisions

## Development Guidelines

### When Building Out This Project

1. **Initialize the project** with `npm init` or `yarn init` and install a smart contract framework (Hardhat recommended for tutorials)
2. **Follow the Diamond Standard reference implementation** at [EIP-2535](https://eips.ethereum.org/EIPS/eip-2535)
3. **Standard contract directory layout**:
   - `contracts/` — Solidity source files
   - `contracts/facets/` — Diamond facet implementations
   - `contracts/interfaces/` — Interface definitions (IDiamondCut, IDiamondLoupe, etc.)
   - `contracts/libraries/` — Shared libraries (LibDiamond, AppStorage)
   - `scripts/` — Deployment and interaction scripts
   - `test/` — Test files
4. **Keep facets small and focused** — each facet should handle a single domain of functionality
5. **Use AppStorage pattern** for shared state across facets to prevent storage layout conflicts

### Code Conventions

- Use Solidity `^0.8.x` for smart contracts
- Follow the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Name facets with a `Facet` suffix (e.g., `DiamondCutFacet.sol`, `DiamondLoupeFacet.sol`)
- Name interfaces with an `I` prefix (e.g., `IDiamondCut.sol`)
- Name libraries with a `Lib` prefix (e.g., `LibDiamond.sol`)

### Build & Test Commands (once configured)

These are the expected commands once the project is set up:

```bash
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy (local network)
npx hardhat run scripts/deploy.js

# Run a local node
npx hardhat node
```

### Environment Variables

Once the project has deployment scripts, expect a `.env` file (gitignored) with:
- `PRIVATE_KEY` — deployer wallet private key
- `RPC_URL` — network RPC endpoint
- `ETHERSCAN_API_KEY` — for contract verification

Never commit `.env` files. Use `.env.example` as a template with placeholder values.

## Key Files to Expect

| File | Purpose |
|---|---|
| `hardhat.config.js` / `hardhat.config.ts` | Hardhat framework configuration |
| `contracts/Diamond.sol` | Main diamond proxy contract |
| `contracts/facets/DiamondCutFacet.sol` | Facet for adding/replacing/removing functions |
| `contracts/facets/DiamondLoupeFacet.sol` | Facet for introspecting the diamond |
| `contracts/facets/OwnershipFacet.sol` | Facet for ownership management |
| `contracts/libraries/LibDiamond.sol` | Core diamond storage and internal functions |
| `scripts/deploy.js` | Diamond deployment script |
| `test/diamondTest.js` | Diamond functionality tests |

## Security Considerations

- Validate all `diamondCut` operations carefully — incorrect cuts can brick the contract
- Ensure storage layout compatibility when upgrading facets
- Never remove the `DiamondCutFacet` unless intentionally making the diamond immutable
- Test facet interactions thoroughly, especially shared storage access
- Use `onlyOwner` or equivalent access control on `diamondCut`
