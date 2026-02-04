# Diamond Standard DAO Governance Questionnaire Contracts

This directory contains the implementation of a **Diamond Standard (EIP-2535)** smart contract system for DAO governance and signer elections.

## What Makes This Special?

🎉 **This is likely the world's first comprehensive questionnaire/assessment system built using the Diamond Standard!**

## Architecture Overview

### Diamond Standard Pattern

The Diamond Standard allows for:
- **Unlimited Contract Size**: Break logic into multiple facets
- **Upgradeable**: Replace individual facets without redeploying everything
- **Shared Storage**: All facets access the same storage via AppStorage pattern
- **Gas Efficient**: Uses delegatecall for function routing

```
┌─────────────────────────────────────────────┐
│              Diamond (Proxy)                │
│  Receives all calls and delegates to facets │
└─────────────┬───────────────────────────────┘
              │
              ├─→ DiamondCutFacet (Upgrade management)
              ├─→ DiamondLoupeFacet (Introspection)
              ├─→ OwnershipFacet (Access control)
              ├─→ NominationFacet (Candidate nominations)
              ├─→ AssessmentFacet (Community assessments)
              ├─→ AvailabilityFacet (Signer status)
              └─→ PerformanceFacet (Performance tracking)
```

## Directory Structure

```
contracts/
├── Diamond.sol                    # Main diamond proxy contract
├── interfaces/
│   ├── IDiamondCut.sol           # Interface for upgrades
│   └── IDiamondLoupe.sol         # Interface for introspection
├── libraries/
│   ├── LibDiamond.sol            # Diamond internal logic
│   └── LibAppStorage.sol         # Shared storage definitions
└── facets/
    ├── DiamondCutFacet.sol       # Upgrade functionality
    ├── DiamondLoupeFacet.sol     # Query functionality
    ├── OwnershipFacet.sol        # Admin management
    ├── NominationFacet.sol       # Candidate nominations
    ├── AssessmentFacet.sol       # Community assessments
    ├── AvailabilityFacet.sol     # Signer availability
    └── PerformanceFacet.sol      # Performance tracking
```

## Core Components

### 1. NominationFacet
Handles candidate nominations for signer positions.

**Key Functions:**
- `nominate(address candidate, string statement)` - Nominate a candidate
- `withdrawNomination(uint256 nominationId)` - Withdraw nomination
- `getNominations()` - Get all nominations
- `getActiveNominations()` - Get non-withdrawn nominations

**Features:**
- Prevents self-nomination
- 280 character limit on statements (link to IPFS for longer)
- Tracks nominator and timestamp

### 2. AssessmentFacet
Community assessment system with 4-trait scoring.

**The 4 Traits (100 points total):**
1. **Technical Competence** (0-100 points)
2. **Reliability & Commitment** (0-100 points)
3. **Communication & Transparency** (0-100 points)
4. **Alignment with DAO Values** (0-100 points)

**Key Functions:**
- `assessCandidate(address candidate, uint8[4] traitScores, string feedback)` - Submit assessment
- `getAggregatedScores(address candidate)` - Get median scores
- `getLeaderboard()` - View all candidates ranked

**Rules:**
- Scores must sum to 100 points
- Minimum 5 points per trait (prevents spam)
- Cannot assess yourself
- Can only assess each candidate once
- Feedback limited to 69 characters

**Score Aggregation:**
- Uses **median** scoring (resistant to outliers)
- Automatically updated on each new assessment
- Efficient QuickSort algorithm for median calculation

### 3. AvailabilityFacet
Tracks signer availability status.

**Status Types:**
```solidity
enum SignerStatus {
    Inactive,  // Not a signer
    Active,    // Currently active
    OnLeave,   // Temporarily unavailable
    Removed    // Permanently removed
}
```

**Key Functions:**
- `updateStatus(SignerStatus newStatus)` - Update your status
- `getActiveSigners()` - List all active signers
- `addSigner(address signer)` - Admin adds new signer
- `batchAddSigners(address[] signers)` - Bulk add signers

### 4. PerformanceFacet
Tracks signature performance and calculates reliability.

**Key Functions:**
- `recordSignature(address signer)` - Record a signature
- `recordMissedSignature(address signer)` - Record a miss
- `calculateReliabilityScore(address signer)` - Get score (0-100)
- `getPerformanceLeaderboard()` - View all signers ranked

**Reliability Formula:**
```
score = (totalSignatures / (totalSignatures + missedSignatures)) * 100
```

### 5. OwnershipFacet
Manages ownership and admin access control.

**Key Functions:**
- `transferOwnership(address newOwner)` - Transfer ownership
- `addAdmin(address admin)` - Add admin
- `removeAdmin(address admin)` - Remove admin
- `isAdmin(address account)` - Check admin status

## Storage Pattern: AppStorage

All facets share the same storage layout using the AppStorage pattern:

```solidity
struct AppStorage {
    // Nomination data
    uint256 nominationCounter;
    mapping(uint256 => Nomination) nominations;
    mapping(address => uint256[]) candidateNominations;

    // Assessment data
    mapping(address => Assessment[]) candidateAssessments;
    mapping(address => AggregatedScores) aggregatedScores;

    // Availability data
    mapping(address => SignerStatus) signerStatus;
    address[] activeSigners;

    // Performance data
    mapping(address => SignerPerformance) signerPerformance;

    // Access control
    address contractOwner;
    mapping(address => bool) isAdmin;

    // Phase control
    bool nominationsOpen;
    bool assessmentsOpen;
}
```

**⚠️ CRITICAL: Never change order of existing fields, only append new ones!**

## Gas Estimates

Based on Sepolia testnet estimates:

| Operation | Gas Cost | USD (estimate) |
|-----------|----------|----------------|
| Nominate candidate | ~50,000 | ~$0.10 |
| Assess candidate | ~80,000 | ~$0.15 |
| Update availability | ~30,000 | ~$0.05 |
| Record signature | ~40,000 | ~$0.08 |
| **Full participation** | ~450,000 | ~$0.85 |

## Upgradeability

One of the key benefits of Diamond Standard is upgradeability:

```javascript
// Example: Upgrade AssessmentFacet to add new features
const NewAssessmentFacet = await ethers.getContractFactory("AssessmentFacetV2");
const newAssessmentFacet = await NewAssessmentFacet.deploy();

const cut = [{
  facetAddress: await newAssessmentFacet.getAddress(),
  action: FacetCutAction.Replace,
  functionSelectors: getSelectors([
    "assessCandidate(address,uint8[4],string)",
    // ... other functions
  ])
}];

await diamondCut.diamondCut(cut, ethers.ZeroAddress, "0x");
```

## Security Considerations

### Access Control
- Owner can: Transfer ownership, add/remove admins, upgrade contracts
- Admins can: Manage phases, add signers, record performance
- Users can: Nominate, assess, update their own status

### Input Validation
- All addresses checked for zero address
- Score totals validated (must equal 100)
- Minimum score per trait enforced (5 points)
- String lengths validated
- Prevents self-nomination and self-assessment

### Reentrancy Protection
- All state changes happen before external calls
- No external calls in critical functions
- Read-only view functions clearly marked

### Storage Safety
- AppStorage pattern prevents storage collisions
- Never change order of existing fields
- Only append new fields to end of structs

## Development Workflow

### Testing
```bash
# Compile contracts
npm run compile

# Run tests
npm test

# Generate gas report
REPORT_GAS=true npm test
```

### Deployment
```bash
# Deploy to local network
npm run node
npm run deploy:local

# Deploy to Sepolia
npm run deploy:sepolia
```

### Interacting with Diamond

```javascript
// Get facet interfaces
const diamond = await ethers.getContractAt("Diamond", diamondAddress);
const nomination = await ethers.getContractAt("NominationFacet", diamondAddress);
const assessment = await ethers.getContractAt("AssessmentFacet", diamondAddress);

// Open nomination phase
await nomination.setNominationPhaseStatus(true);

// Nominate a candidate
await nomination.nominate(candidateAddress, "Great candidate!");

// Open assessment phase
await assessment.setAssessmentPhaseStatus(true);

// Assess candidate
await assessment.assessCandidate(
  candidateAddress,
  [40, 30, 20, 10], // trait scores
  "Strong technical skills"
);

// View leaderboard
const [candidates, scores, totals] = await assessment.getLeaderboard();
```

## Future Enhancements

Potential additions (as new facets or upgrades):

1. **CompensationFacet** - Manage signer compensation proposals
2. **VotingFacet** - On-chain voting for final signer selection
3. **SnapshotIntegration** - Connect to Snapshot for gasless votes
4. **IPFSFacet** - Direct IPFS integration for storing long statements
5. **ReputationFacet** - Long-term reputation tracking across terms
6. **DisputeFacet** - Handle disputes and appeals
7. **MultisigFacet** - Integrate with multisig wallet operations

## Resources

- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)
- [Nick Mudge's Diamond Standard Blog](https://eip2535diamonds.substack.com/)
- [Diamond Standard Reference](https://github.com/mudgen/diamond)
- [Hardhat Documentation](https://hardhat.org/)

## Contributing

Contributions are welcome! Please:
1. Test thoroughly
2. Follow the existing code style
3. Add tests for new features
4. Update documentation
5. Consider gas optimization

## License

MIT License - see LICENSE file for details

---

Built with ❤️ using the Diamond Standard (EIP-2535)
