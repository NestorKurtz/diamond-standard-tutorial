# Standalone DAO Questionnaire

**Ready-to-Deploy Governance Questionnaire** - Single contract, no Diamond complexity!

## What Is This?

A simplified, standalone version of the DAO Governance Questionnaire that you can **deploy and use TODAY**. Perfect for:

- Quick deployment for immediate use
- Testing the questionnaire concept
- DAOs that don't need upgradeability yet
- Sharing with colleagues for review

## Key Features

✅ **4-Trait Assessment System** (100 points total):
- Technical Competence (0-100)
- Reliability & Commitment (0-100)
- Communication & Transparency (0-100)
- Alignment with DAO Values (0-100)

✅ **Candidate Nominations**
- Anyone can nominate candidates
- 280 character statements
- Withdrawal support

✅ **Community Assessments**
- Prevents self-assessment
- One assessment per candidate
- 69-character feedback
- Median-based aggregation

✅ **Real-Time Leaderboard**
- Sorted by total score
- Shows all trait breakdowns
- Updates automatically

## Quick Deploy (Remix)

### Option 1: Deploy in Browser (Fastest)

1. Go to https://remix.ethereum.org/
2. Create new file: `DAOQuestionnaire.sol`
3. Copy/paste the contract code from `DAOQuestionnaire.sol`
4. Compile (Compiler: 0.8.24)
5. Deploy:
   - Network: Sepolia Testnet
   - Contract: DAOQuestionnaire
   - Click "Deploy"
6. Done! 🎉

### Option 2: Deploy with Hardhat

```bash
# In standalone directory
npx hardhat run deploy-standalone.js --network sepolia
```

## How to Use

### Phase 1: Nominations (Admin Opens)

```javascript
// Admin opens nominations
await contract.setNominationPhase(true);

// Users nominate candidates
await contract.nominate(
  "0xCandidateAddress",
  "Excellent technical skills and strong community engagement"
);

// Admin closes nominations
await contract.setNominationPhase(false);
```

### Phase 2: Assessments (Admin Opens)

```javascript
// Admin opens assessments
await contract.setAssessmentPhase(true);

// Users assess candidates (scores must total 100)
await contract.assessCandidate(
  "0xCandidateAddress",
  [40, 30, 20, 10], // [Technical, Reliability, Communication, Values]
  "Strong tech skills, could improve communication"
);

// View leaderboard
const [candidates, scores, totals] = await contract.getLeaderboard();
console.log("Leaderboard:");
for (let i = 0; i < candidates.length; i++) {
  console.log(`${i+1}. ${candidates[i]}: ${totals[i]} points`);
  console.log(`   Tech: ${scores[i][0]}, Reliability: ${scores[i][1]}`);
  console.log(`   Communication: ${scores[i][2]}, Values: ${scores[i][3]}`);
}
```

## Example Workflow

### Step 1: Deploy Contract
```solidity
// Deployed at: 0x123...abc
// Owner: Your wallet address
```

### Step 2: Add Admins (Optional)
```javascript
await contract.addAdmin("0xAdminAddress");
```

### Step 3: Open Nominations
```javascript
await contract.setNominationPhase(true);
```

### Step 4: Community Nominates
```javascript
// Alice nominates Bob
await contract.connect(alice).nominate(
  bob.address,
  "Bob has been active in governance for 2 years. Strong technical background."
);

// Charlie nominates David
await contract.connect(charlie).nominate(
  david.address,
  "David is highly reliable and communicates clearly with the community."
);
```

### Step 5: Close Nominations, Open Assessments
```javascript
await contract.setNominationPhase(false);
await contract.setAssessmentPhase(true);
```

### Step 6: Community Assesses
```javascript
// Eve assesses Bob
await contract.connect(eve).assessCandidate(
  bob.address,
  [45, 25, 20, 10], // Total: 100
  "Great technical skills!"
);

// Frank assesses Bob
await contract.connect(frank).assessCandidate(
  bob.address,
  [40, 30, 20, 10], // Total: 100
  "Very reliable"
);

// George assesses David
await contract.connect(george).assessCandidate(
  david.address,
  [30, 35, 25, 10], // Total: 100
  "Excellent communicator"
);
```

### Step 7: View Results
```javascript
// Get leaderboard
const [candidates, scores, totals] = await contract.getLeaderboard();

// Output:
// 1. Bob (0x123...): 95 points
//    Technical: 42, Reliability: 27, Communication: 20, Values: 10
// 2. David (0x456...): 90 points
//    Technical: 30, Reliability: 35, Communication: 25, Values: 10
```

## Interaction Examples

### JavaScript (ethers.js)

```javascript
const { ethers } = require("ethers");

// Connect to contract
const provider = new ethers.JsonRpcProvider("https://sepolia.infura.io/v3/YOUR-KEY");
const wallet = new ethers.Wallet("YOUR-PRIVATE-KEY", provider);
const contract = new ethers.Contract(contractAddress, abi, wallet);

// Nominate
const tx1 = await contract.nominate(
  "0xCandidate",
  "Excellent candidate with proven track record"
);
await tx1.wait();
console.log("Nominated!");

// Assess
const tx2 = await contract.assessCandidate(
  "0xCandidate",
  [40, 30, 20, 10],
  "Strong technical skills"
);
await tx2.wait();
console.log("Assessment submitted!");

// Get leaderboard
const [candidates, scores, totals] = await contract.getLeaderboard();
console.log("Leaderboard:", candidates, totals);
```

### Python (web3.py)

```python
from web3 import Web3

# Connect
w3 = Web3(Web3.HTTPProvider('https://sepolia.infura.io/v3/YOUR-KEY'))
contract = w3.eth.contract(address=contract_address, abi=abi)

# Nominate
tx_hash = contract.functions.nominate(
    candidate_address,
    "Great candidate!"
).transact({'from': your_address})
w3.eth.wait_for_transaction_receipt(tx_hash)
print("Nominated!")

# Assess
tx_hash = contract.functions.assessCandidate(
    candidate_address,
    [40, 30, 20, 10],
    "Strong skills"
).transact({'from': your_address})
w3.eth.wait_for_transaction_receipt(tx_hash)
print("Assessed!")

# Leaderboard
candidates, scores, totals = contract.functions.getLeaderboard().call()
print("Leaderboard:", list(zip(candidates, totals)))
```

## Frontend Integration

### React Example

```jsx
import { ethers } from 'ethers';
import { useState, useEffect } from 'react';

function DAOQuestionnaire() {
  const [contract, setContract] = useState(null);
  const [leaderboard, setLeaderboard] = useState([]);

  useEffect(() => {
    const init = async () => {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(ADDRESS, ABI, signer);
      setContract(contract);
      await loadLeaderboard(contract);
    };
    init();
  }, []);

  const loadLeaderboard = async (contract) => {
    const [candidates, scores, totals] = await contract.getLeaderboard();
    setLeaderboard(candidates.map((addr, i) => ({
      address: addr,
      total: totals[i],
      scores: scores[i]
    })));
  };

  const nominate = async (candidate, statement) => {
    const tx = await contract.nominate(candidate, statement);
    await tx.wait();
    alert('Nomination submitted!');
  };

  const assess = async (candidate, scores, feedback) => {
    const tx = await contract.assessCandidate(candidate, scores, feedback);
    await tx.wait();
    alert('Assessment submitted!');
    await loadLeaderboard(contract);
  };

  return (
    <div>
      <h1>DAO Questionnaire</h1>

      <h2>Leaderboard</h2>
      {leaderboard.map((item, i) => (
        <div key={i}>
          <h3>#{i+1} {item.address}</h3>
          <p>Total: {item.total.toString()} points</p>
          <ul>
            <li>Technical: {item.scores[0]}</li>
            <li>Reliability: {item.scores[1]}</li>
            <li>Communication: {item.scores[2]}</li>
            <li>Values: {item.scores[3]}</li>
          </ul>
        </div>
      ))}
    </div>
  );
}
```

## Gas Costs (Sepolia)

| Operation | Gas | Estimated USD |
|-----------|-----|---------------|
| Deploy | ~2,500,000 | ~$0.50 |
| Nominate | ~120,000 | ~$0.02 |
| Assess | ~150,000 | ~$0.03 |
| View Leaderboard | 0 (read-only) | Free |

## Differences from Diamond Version

| Feature | Standalone | Diamond |
|---------|-----------|---------|
| **Deployment** | Single contract | Multiple facets |
| **Upgradeability** | ❌ Not upgradeable | ✅ Fully upgradeable |
| **Size Limit** | 24KB max | Unlimited |
| **Complexity** | Simple | Advanced |
| **Gas Cost** | Lower deployment | Higher deployment |
| **Best For** | Quick start, testing | Production, long-term |

## When to Use Which Version?

### Use Standalone If:
- ✅ You need it deployed **today**
- ✅ Testing the concept
- ✅ Small to medium scale
- ✅ Don't need upgradeability yet
- ✅ Want simplicity

### Use Diamond If:
- ✅ Long-term production system
- ✅ Need upgradeability
- ✅ Large scale (many features)
- ✅ Want to add features later
- ✅ Complex governance needs

## Migration Path

When you're ready to upgrade to Diamond:

1. Deploy Diamond version
2. Export data from standalone:
   ```javascript
   // Get all nominations
   const noms = await standalone.getActiveNominations();

   // Get all assessments for each candidate
   for (const nom of noms) {
     const assessments = await standalone.getCandidateAssessments(nom.candidate);
     // Store for migration
   }
   ```
3. Import data to Diamond
4. Announce migration to community
5. Redirect users to new contract

## Support & Questions

- Questions? Open an issue on GitHub
- Want to contribute? Submit a PR
- Need help deploying? Check the main README

## Testing

```bash
# Run tests
npx hardhat test test/standalone.test.js

# With gas reporting
REPORT_GAS=true npx hardhat test test/standalone.test.js
```

## Security Notes

⚠️ **Before Production:**
1. Audit the contract (consider professional audit)
2. Test on testnet thoroughly
3. Start with small group
4. Monitor for issues
5. Have emergency plan

✅ **Built-in Protections:**
- Cannot assess yourself
- Cannot nominate yourself
- One assessment per candidate
- Score validation (must total 100)
- Minimum 5 points per trait
- Admin access control

## License

MIT License - Free to use, modify, and distribute

---

**Ready to deploy?** Copy `DAOQuestionnaire.sol` to Remix and deploy in 2 minutes! 🚀

For the full Diamond version with upgradeability, see the main `contracts/` directory.
