const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Standalone DAO Questionnaire", function () {
  let questionnaire;
  let owner, addr1, addr2, addr3, addr4;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();

    const DAOQuestionnaire = await ethers.getContractFactory("DAOQuestionnaire");
    questionnaire = await DAOQuestionnaire.deploy();
    await questionnaire.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the correct owner", async function () {
      expect(await questionnaire.owner()).to.equal(owner.address);
    });

    it("Should have nominations closed initially", async function () {
      expect(await questionnaire.nominationsOpen()).to.equal(false);
    });

    it("Should have assessments closed initially", async function () {
      expect(await questionnaire.assessmentsOpen()).to.equal(false);
    });

    it("Should set value points to 100", async function () {
      expect(await questionnaire.valuePointsPerAssessment()).to.equal(100);
    });
  });

  describe("Admin Functions", function () {
    it("Should allow owner to add admin", async function () {
      await questionnaire.addAdmin(addr1.address);
      expect(await questionnaire.isAdmin(addr1.address)).to.equal(true);
    });

    it("Should allow owner to remove admin", async function () {
      await questionnaire.addAdmin(addr1.address);
      await questionnaire.removeAdmin(addr1.address);
      expect(await questionnaire.isAdmin(addr1.address)).to.equal(false);
    });

    it("Should allow owner to transfer ownership", async function () {
      await questionnaire.transferOwnership(addr1.address);
      expect(await questionnaire.owner()).to.equal(addr1.address);
    });

    it("Should allow admin to open nominations", async function () {
      await questionnaire.addAdmin(addr1.address);
      await questionnaire.connect(addr1).setNominationPhase(true);
      expect(await questionnaire.nominationsOpen()).to.equal(true);
    });
  });

  describe("Nominations", function () {
    beforeEach(async function () {
      await questionnaire.setNominationPhase(true);
    });

    it("Should allow nominations when open", async function () {
      await expect(
        questionnaire.connect(addr1).nominate(
          addr2.address,
          "Excellent candidate with strong technical skills"
        )
      ).to.emit(questionnaire, "CandidateNominated");
    });

    it("Should prevent self-nomination", async function () {
      await expect(
        questionnaire.connect(addr1).nominate(
          addr1.address,
          "Nominating myself"
        )
      ).to.be.revertedWith("Cannot nominate yourself");
    });

    it("Should prevent nominations when closed", async function () {
      await questionnaire.setNominationPhase(false);

      await expect(
        questionnaire.connect(addr1).nominate(
          addr2.address,
          "Test nomination"
        )
      ).to.be.revertedWith("Nominations closed");
    });

    it("Should enforce statement length limits", async function () {
      const tooLong = "a".repeat(281);

      await expect(
        questionnaire.connect(addr1).nominate(addr2.address, tooLong)
      ).to.be.revertedWith("Invalid statement length");
    });

    it("Should track nominations correctly", async function () {
      await questionnaire.connect(addr1).nominate(addr2.address, "Statement 1");
      expect(await questionnaire.nominationCounter()).to.equal(1);
      expect(await questionnaire.isNominated(addr2.address)).to.equal(true);
    });

    it("Should allow withdrawal of nomination", async function () {
      await questionnaire.connect(addr1).nominate(addr2.address, "Statement");

      await expect(
        questionnaire.connect(addr1).withdrawNomination(1)
      ).to.emit(questionnaire, "NominationWithdrawn");

      const nomination = await questionnaire.nominations(1);
      expect(nomination.withdrawn).to.equal(true);
    });

    it("Should return active nominations", async function () {
      await questionnaire.connect(addr1).nominate(addr2.address, "Statement 1");
      await questionnaire.connect(addr1).nominate(addr3.address, "Statement 2");
      await questionnaire.connect(addr2).nominate(addr4.address, "Statement 3");

      const activeNoms = await questionnaire.getActiveNominations();
      expect(activeNoms.length).to.equal(3);
    });
  });

  describe("Assessments", function () {
    beforeEach(async function () {
      // Open nominations and nominate candidates
      await questionnaire.setNominationPhase(true);
      await questionnaire.connect(addr1).nominate(addr2.address, "Candidate 1");
      await questionnaire.connect(addr1).nominate(addr3.address, "Candidate 2");

      // Close nominations, open assessments
      await questionnaire.setNominationPhase(false);
      await questionnaire.setAssessmentPhase(true);
    });

    it("Should allow valid assessments", async function () {
      const traitScores = [40, 30, 20, 10]; // Total = 100

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          traitScores,
          "Strong technical skills"
        )
      ).to.emit(questionnaire, "CandidateAssessed");
    });

    it("Should reject assessments with invalid total", async function () {
      const invalidScores = [30, 30, 30, 30]; // Total = 120

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          invalidScores,
          "Test"
        )
      ).to.be.revertedWith("Must total 100 points");
    });

    it("Should reject assessments with scores below minimum", async function () {
      const invalidScores = [90, 3, 3, 4]; // Has values < 5

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          invalidScores,
          "Test"
        )
      ).to.be.revertedWith("Minimum 5 per trait");
    });

    it("Should prevent self-assessment", async function () {
      const traitScores = [40, 30, 20, 10];

      await expect(
        questionnaire.connect(addr2).assessCandidate(
          addr2.address,
          traitScores,
          "Self assessment"
        )
      ).to.be.revertedWith("Cannot assess yourself");
    });

    it("Should prevent duplicate assessments", async function () {
      const traitScores = [40, 30, 20, 10];

      await questionnaire.connect(addr1).assessCandidate(
        addr2.address,
        traitScores,
        "First"
      );

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          traitScores,
          "Second"
        )
      ).to.be.revertedWith("Already assessed");
    });

    it("Should prevent assessments when closed", async function () {
      await questionnaire.setAssessmentPhase(false);

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          [40, 30, 20, 10],
          "Test"
        )
      ).to.be.revertedWith("Assessments closed");
    });

    it("Should enforce feedback length limit", async function () {
      const tooLong = "a".repeat(70);

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          [40, 30, 20, 10],
          tooLong
        )
      ).to.be.revertedWith("Feedback too long");
    });

    it("Should calculate aggregated scores", async function () {
      // Multiple assessments
      await questionnaire.connect(addr1).assessCandidate(
        addr2.address,
        [40, 30, 20, 10],
        "Good"
      );

      await questionnaire.connect(addr3).assessCandidate(
        addr2.address,
        [35, 35, 20, 10],
        "Great"
      );

      await questionnaire.connect(addr4).assessCandidate(
        addr2.address,
        [45, 25, 20, 10],
        "Excellent"
      );

      const scores = await questionnaire.getAggregatedScores(addr2.address);
      expect(scores.length).to.equal(4);
      // Median should be calculated
      expect(scores[0]).to.be.greaterThan(0); // Technical
    });

    it("Should return candidate assessments", async function () {
      await questionnaire.connect(addr1).assessCandidate(
        addr2.address,
        [40, 30, 20, 10],
        "Test"
      );

      const assessments = await questionnaire.getCandidateAssessments(addr2.address);
      expect(assessments.length).to.equal(1);
      expect(assessments[0].assessor).to.equal(addr1.address);
    });
  });

  describe("Leaderboard", function () {
    beforeEach(async function () {
      // Setup: Nominate and assess multiple candidates
      await questionnaire.setNominationPhase(true);
      await questionnaire.connect(addr1).nominate(addr2.address, "Candidate 1");
      await questionnaire.connect(addr1).nominate(addr3.address, "Candidate 2");

      await questionnaire.setNominationPhase(false);
      await questionnaire.setAssessmentPhase(true);

      // Assess addr2 (higher scores)
      await questionnaire.connect(addr1).assessCandidate(
        addr2.address,
        [45, 30, 15, 10],
        "Excellent"
      );

      await questionnaire.connect(addr4).assessCandidate(
        addr2.address,
        [40, 35, 15, 10],
        "Great"
      );

      // Assess addr3 (lower scores)
      await questionnaire.connect(addr1).assessCandidate(
        addr3.address,
        [30, 30, 30, 10],
        "Good"
      );
    });

    it("Should return leaderboard sorted by total score", async function () {
      const [candidates, scores, totals] = await questionnaire.getLeaderboard();

      expect(candidates.length).to.equal(2);
      expect(scores.length).to.equal(2);
      expect(totals.length).to.equal(2);

      // Should be sorted descending
      expect(totals[0]).to.be.greaterThanOrEqual(totals[1]);
    });

    it("Should include all trait scores in leaderboard", async function () {
      const [candidates, scores, totals] = await questionnaire.getLeaderboard();

      // Each candidate should have 4 trait scores
      expect(scores[0].length).to.equal(4);
      expect(scores[1].length).to.equal(4);
    });
  });

  describe("Edge Cases", function () {
    it("Should handle zero nominations gracefully", async function () {
      await questionnaire.setNominationPhase(true);
      const activeNoms = await questionnaire.getActiveNominations();
      expect(activeNoms.length).to.equal(0);
    });

    it("Should handle zero assessments gracefully", async function () {
      await questionnaire.setNominationPhase(true);
      await questionnaire.connect(addr1).nominate(addr2.address, "Test");
      await questionnaire.setAssessmentPhase(true);

      const assessments = await questionnaire.getCandidateAssessments(addr2.address);
      expect(assessments.length).to.equal(0);
    });

    it("Should allow exact 69 character feedback", async function () {
      await questionnaire.setNominationPhase(true);
      await questionnaire.connect(addr1).nominate(addr2.address, "Test");
      await questionnaire.setAssessmentPhase(true);

      const exactly69 = "a".repeat(69);

      await expect(
        questionnaire.connect(addr1).assessCandidate(
          addr2.address,
          [40, 30, 20, 10],
          exactly69
        )
      ).to.not.be.reverted;
    });

    it("Should allow exactly 280 character statement", async function () {
      await questionnaire.setNominationPhase(true);

      const exactly280 = "a".repeat(280);

      await expect(
        questionnaire.connect(addr1).nominate(addr2.address, exactly280)
      ).to.not.be.reverted;
    });
  });
});
