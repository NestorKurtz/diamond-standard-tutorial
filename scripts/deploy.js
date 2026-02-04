const { ethers } = require("hardhat");

/**
 * Deploy Diamond Standard DAO Governance Questionnaire System
 */
async function main() {
  console.log("Starting Diamond deployment...\n");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString(), "\n");

  // Deploy facets
  console.log("Deploying facets...");

  const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
  const diamondCutFacet = await DiamondCutFacet.deploy();
  await diamondCutFacet.waitForDeployment();
  console.log("DiamondCutFacet deployed to:", await diamondCutFacet.getAddress());

  const DiamondLoupeFacet = await ethers.getContractFactory("DiamondLoupeFacet");
  const diamondLoupeFacet = await DiamondLoupeFacet.deploy();
  await diamondLoupeFacet.waitForDeployment();
  console.log("DiamondLoupeFacet deployed to:", await diamondLoupeFacet.getAddress());

  const OwnershipFacet = await ethers.getContractFactory("OwnershipFacet");
  const ownershipFacet = await OwnershipFacet.deploy();
  await ownershipFacet.waitForDeployment();
  console.log("OwnershipFacet deployed to:", await ownershipFacet.getAddress());

  const NominationFacet = await ethers.getContractFactory("NominationFacet");
  const nominationFacet = await NominationFacet.deploy();
  await nominationFacet.waitForDeployment();
  console.log("NominationFacet deployed to:", await nominationFacet.getAddress());

  const AssessmentFacet = await ethers.getContractFactory("AssessmentFacet");
  const assessmentFacet = await AssessmentFacet.deploy();
  await assessmentFacet.waitForDeployment();
  console.log("AssessmentFacet deployed to:", await assessmentFacet.getAddress());

  const AvailabilityFacet = await ethers.getContractFactory("AvailabilityFacet");
  const availabilityFacet = await AvailabilityFacet.deploy();
  await availabilityFacet.waitForDeployment();
  console.log("AvailabilityFacet deployed to:", await availabilityFacet.getAddress());

  const PerformanceFacet = await ethers.getContractFactory("PerformanceFacet");
  const performanceFacet = await PerformanceFacet.deploy();
  await performanceFacet.waitForDeployment();
  console.log("PerformanceFacet deployed to:", await performanceFacet.getAddress());

  console.log("\nAll facets deployed successfully!\n");

  // Deploy Diamond
  console.log("Deploying Diamond...");
  const Diamond = await ethers.getContractFactory("Diamond");
  const diamond = await Diamond.deploy(deployer.address, await diamondCutFacet.getAddress());
  await diamond.waitForDeployment();
  const diamondAddress = await diamond.getAddress();
  console.log("Diamond deployed to:", diamondAddress);

  // Get function selectors for each facet
  const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 };

  // Build cut for adding facets
  const cuts = [];

  // DiamondLoupeFacet
  const loupeFunctions = [
    "facets()",
    "facetFunctionSelectors(address)",
    "facetAddresses()",
    "facetAddress(bytes4)",
    "supportsInterface(bytes4)"
  ];
  cuts.push({
    facetAddress: await diamondLoupeFacet.getAddress(),
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(loupeFunctions)
  });

  // OwnershipFacet
  const ownershipFunctions = [
    "transferOwnership(address)",
    "owner()",
    "addAdmin(address)",
    "removeAdmin(address)",
    "isAdmin(address)",
    "batchAddAdmins(address[])"
  ];
  cuts.push({
    facetAddress: await ownershipFacet.getAddress(),
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(ownershipFunctions)
  });

  // NominationFacet
  const nominationFunctions = [
    "nominate(address,string)",
    "withdrawNomination(uint256)",
    "getNominations()",
    "getActiveNominations()",
    "getNominationsForCandidate(address)",
    "getNomination(uint256)",
    "isCandidateNominated(address)",
    "getNominationCount()",
    "setNominationPhaseStatus(bool)",
    "areNominationsOpen()"
  ];
  cuts.push({
    facetAddress: await nominationFacet.getAddress(),
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(nominationFunctions)
  });

  // AssessmentFacet
  const assessmentFunctions = [
    "assessCandidate(address,uint8[4],string)",
    "getAggregatedScores(address)",
    "getAggregatedScoreDetails(address)",
    "getCandidateAssessments(address)",
    "getAssessmentCount(address)",
    "hasAssessedCandidate(address,address)",
    "getLeaderboard()",
    "setAssessmentPhaseStatus(bool)",
    "areAssessmentsOpen()",
    "setValuePointsPerAssessment(uint256)"
  ];
  cuts.push({
    facetAddress: await assessmentFacet.getAddress(),
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(assessmentFunctions)
  });

  // AvailabilityFacet
  const availabilityFunctions = [
    "updateStatus(uint8)",
    "getSignerStatus(address)",
    "getActiveSigners()",
    "getActiveSignerCount()",
    "getSignerJoinedTimestamp(address)",
    "isActiveSigner(address)",
    "getAllSignerStatuses()",
    "addSigner(address)",
    "removeSigner(address)",
    "batchAddSigners(address[])"
  ];
  cuts.push({
    facetAddress: await availabilityFacet.getAddress(),
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(availabilityFunctions)
  });

  // PerformanceFacet
  const performanceFunctions = [
    "recordSignature(address)",
    "recordMissedSignature(address)",
    "batchRecordSignatures(address[])",
    "calculateReliabilityScore(address)",
    "getSignerPerformance(address)",
    "getBatchSignerPerformance(address[])",
    "getPerformanceLeaderboard()",
    "getUnderperformingSigners(uint8)",
    "setSignatureThreshold(uint256)",
    "getSignatureThreshold()",
    "resetSignerPerformance(address)"
  ];
  cuts.push({
    facetAddress: await performanceFacet.getAddress(),
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(performanceFunctions)
  });

  // Add facets to diamond
  console.log("\nAdding facets to Diamond...");
  const diamondCut = await ethers.getContractAt("IDiamondCut", diamondAddress);
  const tx = await diamondCut.diamondCut(cuts, ethers.ZeroAddress, "0x");
  await tx.wait();
  console.log("Facets added successfully!");

  // Verify installation
  console.log("\nVerifying Diamond installation...");
  const diamondLoupe = await ethers.getContractAt("IDiamondLoupe", diamondAddress);
  const facets = await diamondLoupe.facets();
  console.log("Total facets installed:", facets.length);
  console.log("\nFacet details:");
  for (const facet of facets) {
    console.log(`  ${facet.facetAddress}: ${facet.functionSelectors.length} functions`);
  }

  console.log("\n=== Deployment Summary ===");
  console.log("Diamond Address:", diamondAddress);
  console.log("Owner:", deployer.address);
  console.log("\nFacet Addresses:");
  console.log("  DiamondCutFacet:", await diamondCutFacet.getAddress());
  console.log("  DiamondLoupeFacet:", await diamondLoupeFacet.getAddress());
  console.log("  OwnershipFacet:", await ownershipFacet.getAddress());
  console.log("  NominationFacet:", await nominationFacet.getAddress());
  console.log("  AssessmentFacet:", await assessmentFacet.getAddress());
  console.log("  AvailabilityFacet:", await availabilityFacet.getAddress());
  console.log("  PerformanceFacet:", await performanceFacet.getAddress());
  console.log("\n=== Deployment Complete ===\n");

  // Save deployment info
  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    chainId: (await ethers.provider.getNetwork()).chainId.toString(),
    deployer: deployer.address,
    diamond: diamondAddress,
    facets: {
      DiamondCutFacet: await diamondCutFacet.getAddress(),
      DiamondLoupeFacet: await diamondLoupeFacet.getAddress(),
      OwnershipFacet: await ownershipFacet.getAddress(),
      NominationFacet: await nominationFacet.getAddress(),
      AssessmentFacet: await assessmentFacet.getAddress(),
      AvailabilityFacet: await availabilityFacet.getAddress(),
      PerformanceFacet: await performanceFacet.getAddress()
    },
    timestamp: new Date().toISOString()
  };

  const fs = require("fs");
  fs.writeFileSync(
    "deployment.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("Deployment info saved to deployment.json\n");
}

// Helper function to get function selectors
function getSelectors(functionSignatures) {
  return functionSignatures.map(sig => {
    return ethers.id(sig).slice(0, 10);
  });
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
