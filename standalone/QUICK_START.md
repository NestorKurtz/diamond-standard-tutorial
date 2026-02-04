# Quick Start - Deploy Today! 🚀

**Time to deploy: 5 minutes**

## For Non-Technical Users (Remix - Easiest)

### Step 1: Open Remix (2 minutes)

1. Go to https://remix.ethereum.org/
2. Click "File explorer" on left
3. Create new file: `DAOQuestionnaire.sol`
4. Copy/paste the entire contract code from `DAOQuestionnaire.sol`

### Step 2: Compile (30 seconds)

1. Click "Solidity Compiler" icon on left (looks like 'S')
2. Select compiler version: `0.8.24`
3. Click "Compile DAOQuestionnaire.sol"
4. Wait for green checkmark ✅

### Step 3: Deploy (2 minutes)

1. Click "Deploy & Run" icon on left (looks like Ethereum logo)
2. Environment: Select "Injected Provider - MetaMask"
   - MetaMask will pop up - click "Connect"
3. Contract: Select "DAOQuestionnaire"
4. Click orange "Deploy" button
5. MetaMask pops up - click "Confirm"
6. Wait 15 seconds for confirmation
7. **DONE!** ✅ Copy contract address from console

### Step 4: Use It

In Remix "Deployed Contracts" section at bottom:

**Open Nominations:**
```
Click "setNominationPhase"
Enter: true
Click "transact"
Confirm in MetaMask
```

**Nominate Someone:**
```
Click "nominate"
candidate: 0x... (their wallet address)
statement: "This person is excellent because..."
Click "transact"
```

**Open Assessments:**
```
Click "setAssessmentPhase"
Enter: true
Click "transact"
```

**Assess Candidate:**
```
Click "assessCandidate"
candidate: 0x...
traitScores: [40,30,20,10]  (must total 100)
feedback: "Great technical skills"
Click "transact"
```

**View Leaderboard:**
```
Click "getLeaderboard"
Click "call" (free, no gas)
See results below!
```

---

## For Technical Users (Hardhat)

```bash
# Clone or copy files
cd standalone/

# Create hardhat.config.js
cat > hardhat.config.js << 'EOF'
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
EOF

# Create .env file
cat > .env << 'EOF'
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY
PRIVATE_KEY=your-private-key-here
EOF

# Install
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# Deploy
npx hardhat run deploy-standalone.js --network sepolia
```

**Copy the contract address from output!**

---

## Share With Colleagues

### What to Send Them

**Email/Message Template:**

```
Subject: DAO Questionnaire - Ready for Testing!

Hi team,

I've deployed our DAO governance questionnaire system:

Contract Address: 0x... (YOUR ADDRESS HERE)
Network: Sepolia Testnet
Explorer: https://sepolia.etherscan.io/address/0x...

How to participate:

1. Get Sepolia ETH: https://sepoliafaucet.com/
2. Go to contract on Etherscan
3. Connect wallet
4. Use "Write Contract" tab

Current Phase: [Nominations/Assessments]

Functions to use:
- nominate(address, string) - Nominate a candidate
- assessCandidate(address, [40,30,20,10], "feedback") - Assess (scores must total 100)
- getLeaderboard() - View results (Read Contract tab, free)

Questions? Reply to this email.
```

### Quick Tutorial for Team

**Nominating:**
1. Go to Etherscan → Contract → Write Contract → Connect Wallet
2. Find `nominate` function
3. Fill in:
   - `candidate`: Wallet address of person you're nominating
   - `statement`: Why you're nominating them (max 280 chars)
4. Click Write → Confirm in MetaMask

**Assessing:**
1. Find `assessCandidate` function
2. Fill in:
   - `candidate`: Address of person you're assessing
   - `traitScores`: `[40,30,20,10]` (4 numbers that total 100)
     - Technical, Reliability, Communication, Values
     - Minimum 5 per trait
   - `feedback`: Short comment (max 69 chars)
3. Click Write → Confirm in MetaMask

**Viewing Results:**
1. Go to "Read Contract" tab
2. Find `getLeaderboard`
3. Click "Query" (free, no wallet needed)
4. See ranked candidates with scores!

---

## Cost Breakdown

**Sepolia Testnet (Testing):**
- Deploy: ~$0.50
- Nominate: ~$0.02
- Assess: ~$0.03
- View: FREE ✅

**Total for full participation: ~$0.10**

Get Sepolia ETH free from:
- https://sepoliafaucet.com/
- https://faucet.quicknode.com/ethereum/sepolia

---

## Example Interaction (JavaScript)

For developers who want to interact programmatically:

```javascript
const { ethers } = require("ethers");

// Connect
const provider = new ethers.JsonRpcProvider("https://sepolia.infura.io/v3/YOUR-KEY");
const wallet = new ethers.Wallet("YOUR-PRIVATE-KEY", provider);

// Contract
const address = "0x..."; // Your deployed address
const abi = [ /* Get from Remix or Etherscan */ ];
const contract = new ethers.Contract(address, abi, wallet);

// Nominate
const tx1 = await contract.nominate(
  "0xCandidateAddress",
  "This person has excellent technical skills and communication"
);
await tx1.wait();
console.log("Nominated!");

// Assess (scores must total 100)
const tx2 = await contract.assessCandidate(
  "0xCandidateAddress",
  [40, 30, 20, 10], // Technical, Reliability, Communication, Values
  "Strong technical background!"
);
await tx2.wait();
console.log("Assessed!");

// View leaderboard (free, read-only)
const [candidates, scores, totals] = await contract.getLeaderboard();
console.log("Leaderboard:");
for (let i = 0; i < candidates.length; i++) {
  console.log(`${i+1}. ${candidates[i]}: ${totals[i]} points`);
  console.log(`   Technical: ${scores[i][0]}, Reliability: ${scores[i][1]}`);
  console.log(`   Communication: ${scores[i][2]}, Values: ${scores[i][3]}`);
}
```

---

## Troubleshooting

**"Nominations closed"**
→ Owner needs to call `setNominationPhase(true)`

**"Assessments closed"**
→ Owner needs to call `setAssessmentPhase(true)`

**"Cannot nominate yourself"**
→ You're trying to nominate your own wallet. Have someone else nominate you!

**"Cannot assess yourself"**
→ You can't assess yourself. Assessment must come from others.

**"Already assessed"**
→ You already assessed this candidate. Each person can only assess once per candidate.

**"Must total 100 points"**
→ Your 4 trait scores must add up to exactly 100. Example: [40,30,20,10] ✅

**"Minimum 5 per trait"**
→ Each of the 4 scores must be at least 5. Example: [97,1,1,1] ❌

**"Not nominated"**
→ The person you're trying to assess hasn't been nominated yet.

**"Statement too long"**
→ Nomination statement max 280 characters. Assessment feedback max 69 characters.

---

## Next Steps After Testing

1. ✅ Test on Sepolia testnet (free)
2. ✅ Gather feedback from team
3. ✅ Refine process if needed
4. ✅ When ready, deploy to mainnet
5. ✅ Consider upgrading to Diamond version for production

---

## Need Help?

- Check main README.md
- See standalone/README.md for detailed docs
- Open issue on GitHub
- Ask in team chat

---

**You're ready to go!** Deploy in Remix now and share with your team. 🎉
