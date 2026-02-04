const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Diamond Governance Questionnaire System", function () {
  let diamond;
  let diamondAddress;
  let owner, addr1, addr2, addr3, addr4;
  let nominationFacet, assessmentFacet, availabilityFacet, performanceFacet, ownershipFacet;

  before(async function () {
    [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();

    // Deploy Diamond and all facets
    const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
    const diamondCutFacet = await DiamondCutFacet.deploy();
    await diamondCutFacet.waitForDeployment();

    const Diamond = await ethers.getContractFactory("Diamond");
    diamond = await Diamond.deploy(owner.address, await diamondCutFacet.getAddress());
    await diamond.waitForDeployment();
    diamondAddress = await diamond.getAddress();

    // Deploy all facets
    const DiamondLoupeFacet = await ethers.getContractFactory("DiamondLoupeFacet");
    const diamondLoupeFacet = await DiamondLoupeFacet.deploy();
    await diamondLoupeFacet.waitForDeployment();

    const OwnershipFacet = await ethers.getContractFactory("OwnershipFacet");
    const ownershipFacetContract = await OwnershipFacet.deploy();
    await ownershipFacetContract.waitForDeployment();

    const NominationFacet = await ethers.getContractFactory("NominationFacet");
    const nominationFacetContract = await NominationFacet.deploy();
    await nominationFacetContract.waitForDeployment();

    const AssessmentFacet = await ethers.getContractFactory("AssessmentFacet");
    const assessmentFacetContract = await AssessmentFacet.deploy();
    await assessmentFacetContract.waitForDeployment();

    const AvailabilityFacet = await ethers.getContractFactory("AvailabilityFacet");
    const availabilityFacetContract = await AvailabilityFacet.deploy();
    await availabilityFacetContract.waitForDeployment();

    const PerformanceFacet = await ethers.getContractFactory("PerformanceFacet");
    const performanceFacetContract = await PerformanceFacet.deploy();
    await performanceFacetContract.waitForDeployment();

    // Get function selectors
    const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 };

    const getSelectors = (functionSignatures) => {
      return functionSignatures.map(sig => ethers.id(sig).slice(0, 10));
    };

    const cuts = [
      {
        facetAddress: await diamondLoupeFacet.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: getSelectors([
          "facets()",
          "facetFunctionSelectors(address)",
          "facetAddresses()",
          "facetAddress(bytes4)",
          "supportsInterface(bytes4)"
        ])
      },
      {
        facetAddress: await ownershipFacetContract.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: getSelectors([
          "transferOwnership(address)",
          "owner()",
          "addAdmin(address)",
          "removeAdmin(address)",
          "isAdmin(address)",
          "batchAddAdmins(address[])"
        ])
      },
      {
        facetAddress: await nominationFacetContract.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: getSelectors([
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
        ])
      },
      {
        facetAddress: await assessmentFacetContract.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: getSelectors([
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
        ])
      },
      {
        facetAddress: await availabilityFacetContract.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: getSelectors([
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
        ])
      },
      {
        facetAddress: await performanceFacetContract.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: getSelectors([
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
        ])
      }
    ];

    // Add facets to diamond
    const diamondCut = await ethers.getContractAt("IDiamondCut", diamondAddress);
    await diamondCut.diamondCut(cuts, ethers.ZeroAddress, "0x");

    // Get facet interfaces
    nominationFacet = await ethers.getContractAt("NominationFacet", diamondAddress);
    assessmentFacet = await ethers.getContractAt("AssessmentFacet", diamondAddress);
    availabilityFacet = await ethers.getContractAt("AvailabilityFacet", diamondAddress);
    performanceFacet = await ethers.getContractAt("PerformanceFacet", diamondAddress);
    ownershipFacet = await ethers.getContractAt("OwnershipFacet", diamondAddress);
  });

  describe("Deployment", function () {
    it("Should deploy Diamond successfully", async function () {
      expect(diamondAddress).to.not.equal(ethers.ZeroAddress);
    });

    it("Should set the correct owner", async function () {
      expect(await ownershipFacet.owner()).to.equal(owner.address);
    });

    it("Should have nominations closed initially", async function () {
      expect(await nominationFacet.areNominationsOpen()).to.equal(false);
    });

    it("Should have assessments closed initially", async function () {
      expect(await assessmentFacet.areAssessmentsOpen()).to.equal(false);
    });
  });

  describe("Nomination Phase", function () {
    before(async function () {
      // Open nominations
      await nominationFacet.setNominationPhaseStatus(true);
    });

    it("Should allow nominations when open", async function () {
      await expect(
        nominationFacet.connect(addr1).nominate(
          addr2.address,
          "Great candidate with strong technical skills"
        )
      ).to.emit(nominationFacet, "CandidateNominated");
    });

    it("Should prevent self-nomination", async function () {
      await expect(
        nominationFacet.connect(addr1).nominate(
          addr1.address,
          "Nominating myself"
        )
      ).to.be.revertedWith("Cannot nominate yourself");
    });

    it("Should track nominations correctly", async function () {
      const count = await nominationFacet.getNominationCount();
      expect(count).to.equal(1);
    });

    it("Should allow withdrawal of nomination", async function () {
      await expect(
        nominationFacet.connect(addr1).withdrawNomination(1)
      ).to.emit(nominationFacet, "NominationWithdrawn");
    });

    it("Should nominate multiple candidates", async function () {
      await nominationFacet.connect(addr1).nominate(addr2.address, "Candidate 2 statement");
      await nominationFacet.connect(addr1).nominate(addr3.address, "Candidate 3 statement");
      await nominationFacet.connect(addr2).nominate(addr4.address, "Candidate 4 statement");

      const activeNominations = await nominationFacet.getActiveNominations();
      expect(activeNominations.length).to.be.greaterThan(0);
    });
  });

  describe("Assessment Phase", function () {
    before(async function () {
      // Open assessments
      await assessmentFacet.setAssessmentPhaseStatus(true);
    });

    it("Should allow valid assessments", async function () {
      const traitScores = [40, 30, 20, 10]; // Total = 100

      await expect(
        assessmentFacet.connect(addr1).assessCandidate(
          addr2.address,
          traitScores,
          "Strong technical skills, could improve communication"
        )
      ).to.emit(assessmentFacet, "CandidateAssessed");
    });

    it("Should reject assessments with invalid total", async function () {
      const invalidScores = [30, 30, 30, 30]; // Total = 120

      await expect(
        assessmentFacet.connect(addr3).assessCandidate(
          addr2.address,
          invalidScores,
          "Test feedback"
        )
      ).to.be.revertedWith("Scores must total value points per assessment");
    });

    it("Should reject assessments with scores below minimum", async function () {
      const invalidScores = [90, 3, 3, 4]; // Has values < 5

      await expect(
        assessmentFacet.connect(addr3).assessCandidate(
          addr2.address,
          invalidScores,
          "Test feedback"
        )
      ).to.be.revertedWith("Minimum 5 points per trait");
    });

    it("Should prevent self-assessment", async function () {
      const traitScores = [40, 30, 20, 10];

      await expect(
        assessmentFacet.connect(addr2).assessCandidate(
          addr2.address,
          traitScores,
          "Self assessment"
        )
      ).to.be.revertedWith("Cannot assess yourself");
    });

    it("Should prevent duplicate assessments", async function () {
      const traitScores = [40, 30, 20, 10];

      await expect(
        assessmentFacet.connect(addr1).assessCandidate(
          addr2.address,
          traitScores,
          "Second assessment"
        )
      ).to.be.revertedWith("Already assessed this candidate");
    });

    it("Should calculate aggregated scores", async function () {
      // Add more assessments
      await assessmentFacet.connect(addr3).assessCandidate(
        addr2.address,
        [35, 35, 20, 10],
        "Good candidate"
      );

      const aggregated = await assessmentFacet.getAggregatedScores(addr2.address);
      expect(aggregated.length).to.equal(4);
    });

    it("Should generate leaderboard", async function () {
      const [candidates, scores, totalScores] = await assessmentFacet.getLeaderboard();
      expect(candidates.length).to.be.greaterThan(0);
      expect(scores.length).to.equal(candidates.length);
      expect(totalScores.length).to.equal(candidates.length);
    });
  });

  describe("Availability Management", function () {
    it("Should allow owner to add signers", async function () {
      await expect(
        availabilityFacet.addSigner(addr1.address)
      ).to.emit(availabilityFacet, "SignerAdded");
    });

    it("Should allow signers to update status", async function () {
      await expect(
        availabilityFacet.connect(addr1).updateStatus(1) // Active
      ).to.emit(availabilityFacet, "SignerStatusUpdated");
    });

    it("Should track active signers", async function () {
      const activeSigners = await availabilityFacet.getActiveSigners();
      expect(activeSigners.length).to.be.greaterThan(0);
      expect(activeSigners).to.include(addr1.address);
    });

    it("Should allow batch adding signers", async function () {
      await availabilityFacet.batchAddSigners([addr2.address, addr3.address]);
      const activeSigners = await availabilityFacet.getActiveSigners();
      expect(activeSigners.length).to.be.greaterThan(1);
    });
  });

  describe("Performance Tracking", function () {
    it("Should record signatures", async function () {
      await expect(
        performanceFacet.recordSignature(addr1.address)
      ).to.emit(performanceFacet, "SignatureRecorded");
    });

    it("Should calculate reliability score", async function () {
      const score = await performanceFacet.calculateReliabilityScore(addr1.address);
      expect(score).to.equal(100); // 100% with only signatures, no misses
    });

    it("Should handle missed signatures", async function () {
      await performanceFacet.recordMissedSignature(addr1.address);
      const score = await performanceFacet.calculateReliabilityScore(addr1.address);
      expect(score).to.be.lessThan(100);
    });

    it("Should batch record signatures", async function () {
      await performanceFacet.batchRecordSignatures([
        addr1.address,
        addr2.address,
        addr3.address
      ]);

      const perf = await performanceFacet.getSignerPerformance(addr1.address);
      expect(perf.totalSignatures).to.be.greaterThan(1);
    });

    it("Should generate performance leaderboard", async function () {
      const [signers, scores, totalSigs, missedSigs] =
        await performanceFacet.getPerformanceLeaderboard();

      expect(signers.length).to.be.greaterThan(0);
      expect(scores.length).to.equal(signers.length);
    });
  });

  describe("Admin Management", function () {
    it("Should allow owner to add admins", async function () {
      await expect(
        ownershipFacet.addAdmin(addr4.address)
      ).to.emit(ownershipFacet, "AdminAdded");
    });

    it("Should verify admin status", async function () {
      expect(await ownershipFacet.isAdmin(addr4.address)).to.equal(true);
    });

    it("Should allow admin to perform admin actions", async function () {
      await ownershipFacet.addAdmin(addr4.address);
      await expect(
        nominationFacet.connect(addr4).setNominationPhaseStatus(false)
      ).to.not.be.reverted;
    });

    it("Should allow owner to remove admins", async function () {
      await expect(
        ownershipFacet.removeAdmin(addr4.address)
      ).to.emit(ownershipFacet, "AdminRemoved");

      expect(await ownershipFacet.isAdmin(addr4.address)).to.equal(false);
    });
  });
});
