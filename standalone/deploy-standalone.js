const { ethers } = require("hardhat");
const fs = require("fs");

/**
 * Deploy Standalone DAO Questionnaire
 * Simple, single-contract deployment
 */
async function main() {
  console.log("=".repeat(50));
  console.log("Deploying Standalone DAO Questionnaire");
  console.log("=".repeat(50));
  console.log();

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");
  console.log();

  // Deploy contract
  console.log("Deploying DAOQuestionnaire...");
  const DAOQuestionnaire = await ethers.getContractFactory("DAOQuestionnaire");
  const questionnaire = await DAOQuestionnaire.deploy();
  await questionnaire.waitForDeployment();

  const address = await questionnaire.getAddress();
  console.log("✅ DAOQuestionnaire deployed to:", address);
  console.log();

  // Verify deployment
  console.log("Verifying deployment...");
  const owner = await questionnaire.owner();
  console.log("Contract owner:", owner);
  console.log("Nominations open:", await questionnaire.nominationsOpen());
  console.log("Assessments open:", await questionnaire.assessmentsOpen());
  console.log();

  // Save deployment info
  const network = await ethers.provider.getNetwork();
  const deploymentInfo = {
    network: network.name,
    chainId: network.chainId.toString(),
    contractAddress: address,
    deployer: deployer.address,
    deployedAt: new Date().toISOString(),
    contractName: "DAOQuestionnaire",
    version: "1.0.0-standalone"
  };

  const filename = `deployment-standalone-${network.name}.json`;
  fs.writeFileSync(
    filename,
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("=".repeat(50));
  console.log("📋 Deployment Summary");
  console.log("=".repeat(50));
  console.log("Network:", network.name);
  console.log("Chain ID:", network.chainId.toString());
  console.log("Contract Address:", address);
  console.log("Deployer:", deployer.address);
  console.log("Deployment file:", filename);
  console.log();

  console.log("=".repeat(50));
  console.log("🎯 Next Steps");
  console.log("=".repeat(50));
  console.log("1. Open nominations:");
  console.log(`   await questionnaire.setNominationPhase(true)`);
  console.log();
  console.log("2. Users nominate candidates:");
  console.log(`   await questionnaire.nominate(candidateAddress, "statement")`);
  console.log();
  console.log("3. Open assessments:");
  console.log(`   await questionnaire.setAssessmentPhase(true)`);
  console.log();
  console.log("4. Users assess candidates:");
  console.log(`   await questionnaire.assessCandidate(candidate, [40,30,20,10], "feedback")`);
  console.log();
  console.log("5. View leaderboard:");
  console.log(`   await questionnaire.getLeaderboard()`);
  console.log();

  if (network.name === "sepolia") {
    console.log("=".repeat(50));
    console.log("📝 Verify on Etherscan");
    console.log("=".repeat(50));
    console.log("Run:");
    console.log(`npx hardhat verify --network sepolia ${address}`);
    console.log();
  }

  console.log("=".repeat(50));
  console.log("✅ Deployment Complete!");
  console.log("=".repeat(50));
  console.log();

  console.log("Contract ABI saved. To interact:");
  console.log("1. Copy contract address:", address);
  console.log("2. Use with ethers.js, web3.js, or Remix");
  console.log("3. See standalone/README.md for examples");
  console.log();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
