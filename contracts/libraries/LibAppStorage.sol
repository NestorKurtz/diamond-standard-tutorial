// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title LibAppStorage
 * @notice Shared storage library for Diamond Standard DAO Governance Questionnaire
 * @dev Uses the AppStorage pattern - all facets share this storage layout
 */
library LibAppStorage {
    // Status enum for signer availability
    enum SignerStatus {
        Inactive,
        Active,
        OnLeave,
        Removed
    }

    // Nomination struct
    struct Nomination {
        uint256 id;
        address candidate;
        address nominator;
        string statement;
        uint256 timestamp;
        bool withdrawn;
    }

    // Assessment struct with 4 trait scores
    struct Assessment {
        address assessor;
        address candidate;
        uint8[4] traitScores; // [Technical, Reliability, Communication, Values]
        string feedback; // Max 69 characters
        uint256 timestamp;
    }

    // Aggregated scores for a candidate
    struct AggregatedScores {
        uint8[4] medianScores;
        uint256 totalAssessments;
        uint256 lastUpdated;
    }

    // Signer performance tracking
    struct SignerPerformance {
        uint256 totalSignatures;
        uint256 missedSignatures;
        uint256 lastSignatureTimestamp;
        uint8 reliabilityScore; // 0-100
    }

    // Compensation proposal
    struct CompensationProposal {
        uint256 termLengthMonths;
        uint256 compensationAmount; // in USDC wei
        PaymentMethod paymentMethod;
        bool finalized;
    }

    enum PaymentMethod {
        LumpSum,
        Quarterly,
        PerformanceBased,
        Hybrid
    }

    // Main storage struct - NEVER change order of existing fields, only append!
    struct AppStorage {
        // Nomination storage
        uint256 nominationCounter;
        mapping(uint256 => Nomination) nominations;
        mapping(address => uint256[]) candidateNominations;
        mapping(address => bool) isNominated;

        // Assessment storage
        mapping(address => Assessment[]) candidateAssessments;
        mapping(address => AggregatedScores) aggregatedScores;
        mapping(address => mapping(address => bool)) hasAssessed; // assessor => candidate => bool
        uint256 valuePointsPerAssessment; // Default: 100

        // Availability storage
        mapping(address => SignerStatus) signerStatus;
        address[] activeSigners;
        mapping(address => uint256) signerJoinedTimestamp;

        // Performance storage
        mapping(address => SignerPerformance) signerPerformance;
        uint256 signatureThreshold; // Minimum signatures expected per term

        // Compensation storage
        CompensationProposal currentCompensation;
        mapping(uint256 => CompensationProposal) compensationHistory;

        // Access control
        address contractOwner;
        mapping(address => bool) isAdmin;

        // Phase control
        bool nominationsOpen;
        bool assessmentsOpen;
        uint256 phaseStartTime;
        uint256 phaseDuration;
    }

    /**
     * @dev Returns the storage pointer to AppStorage
     */
    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
