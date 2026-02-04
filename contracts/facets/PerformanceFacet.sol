// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

/**
 * @title PerformanceFacet
 * @notice Tracks signer performance and calculates reliability scores
 * @dev Part of Diamond Standard DAO Governance Questionnaire System
 */
contract PerformanceFacet {
    event SignatureRecorded(
        address indexed signer,
        uint256 timestamp,
        uint256 totalSignatures
    );

    event MissedSignatureRecorded(
        address indexed signer,
        uint256 timestamp,
        uint256 totalMissed
    );

    event ReliabilityScoreUpdated(
        address indexed signer,
        uint8 newScore,
        uint256 timestamp
    );

    /**
     * @notice Record a signature by a signer (admin/automated system only)
     * @param signer Address of the signer
     */
    function recordSignature(address signer) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");
        require(signer != address(0), "Invalid signer address");

        LibAppStorage.SignerPerformance storage perf = s.signerPerformance[signer];

        perf.totalSignatures++;
        perf.lastSignatureTimestamp = block.timestamp;

        // Recalculate reliability score
        _updateReliabilityScore(signer);

        emit SignatureRecorded(signer, block.timestamp, perf.totalSignatures);
    }

    /**
     * @notice Record a missed signature by a signer (admin/automated system only)
     * @param signer Address of the signer
     */
    function recordMissedSignature(address signer) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");
        require(signer != address(0), "Invalid signer address");

        LibAppStorage.SignerPerformance storage perf = s.signerPerformance[signer];

        perf.missedSignatures++;

        // Recalculate reliability score
        _updateReliabilityScore(signer);

        emit MissedSignatureRecorded(signer, block.timestamp, perf.missedSignatures);
    }

    /**
     * @notice Batch record signatures for multiple signers
     * @param signers Array of signer addresses
     */
    function batchRecordSignatures(address[] calldata signers) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        for (uint256 i = 0; i < signers.length; i++) {
            address signer = signers[i];
            if (signer != address(0)) {
                LibAppStorage.SignerPerformance storage perf = s.signerPerformance[signer];
                perf.totalSignatures++;
                perf.lastSignatureTimestamp = block.timestamp;
                _updateReliabilityScore(signer);
                emit SignatureRecorded(signer, block.timestamp, perf.totalSignatures);
            }
        }
    }

    /**
     * @notice Calculate reliability score for a signer (0-100)
     * @param signer Address of the signer
     * @return score Reliability score (0-100)
     */
    function calculateReliabilityScore(address signer)
        external
        view
        returns (uint8)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.signerPerformance[signer].reliabilityScore;
    }

    /**
     * @notice Get signer performance details
     * @param signer Address of the signer
     * @return performance SignerPerformance struct
     */
    function getSignerPerformance(address signer)
        external
        view
        returns (LibAppStorage.SignerPerformance memory)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.signerPerformance[signer];
    }

    /**
     * @notice Get performance metrics for multiple signers
     * @param signers Array of signer addresses
     * @return performances Array of performance structs
     */
    function getBatchSignerPerformance(address[] calldata signers)
        external
        view
        returns (LibAppStorage.SignerPerformance[] memory performances)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        performances = new LibAppStorage.SignerPerformance[](signers.length);

        for (uint256 i = 0; i < signers.length; i++) {
            performances[i] = s.signerPerformance[signers[i]];
        }

        return performances;
    }

    /**
     * @notice Get leaderboard of signers sorted by reliability
     * @return signers Array of signer addresses
     * @return scores Array of reliability scores
     * @return totalSigs Array of total signatures
     * @return missedSigs Array of missed signatures
     */
    function getPerformanceLeaderboard()
        external
        view
        returns (
            address[] memory signers,
            uint8[] memory scores,
            uint256[] memory totalSigs,
            uint256[] memory missedSigs
        )
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        uint256 signerCount = s.activeSigners.length;

        signers = new address[](signerCount);
        scores = new uint8[](signerCount);
        totalSigs = new uint256[](signerCount);
        missedSigs = new uint256[](signerCount);

        for (uint256 i = 0; i < signerCount; i++) {
            address signer = s.activeSigners[i];
            LibAppStorage.SignerPerformance storage perf = s.signerPerformance[signer];

            signers[i] = signer;
            scores[i] = perf.reliabilityScore;
            totalSigs[i] = perf.totalSignatures;
            missedSigs[i] = perf.missedSignatures;
        }

        // Simple bubble sort by score (descending)
        for (uint256 i = 0; i < signerCount; i++) {
            for (uint256 j = i + 1; j < signerCount; j++) {
                if (scores[j] > scores[i]) {
                    // Swap all parallel arrays
                    (signers[i], signers[j]) = (signers[j], signers[i]);
                    (scores[i], scores[j]) = (scores[j], scores[i]);
                    (totalSigs[i], totalSigs[j]) = (totalSigs[j], totalSigs[i]);
                    (missedSigs[i], missedSigs[j]) = (missedSigs[j], missedSigs[i]);
                }
            }
        }

        return (signers, scores, totalSigs, missedSigs);
    }

    /**
     * @notice Get signers with reliability score below threshold
     * @param threshold Minimum acceptable score (0-100)
     * @return underperformers Array of underperforming signer addresses
     * @return theirScores Array of their reliability scores
     */
    function getUnderperformingSigners(uint8 threshold)
        external
        view
        returns (address[] memory underperformers, uint8[] memory theirScores)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        // Count underperformers
        uint256 count = 0;
        for (uint256 i = 0; i < s.activeSigners.length; i++) {
            address signer = s.activeSigners[i];
            if (s.signerPerformance[signer].reliabilityScore < threshold) {
                count++;
            }
        }

        underperformers = new address[](count);
        theirScores = new uint8[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < s.activeSigners.length; i++) {
            address signer = s.activeSigners[i];
            uint8 score = s.signerPerformance[signer].reliabilityScore;
            if (score < threshold) {
                underperformers[index] = signer;
                theirScores[index] = score;
                index++;
            }
        }

        return (underperformers, theirScores);
    }

    // Admin functions

    /**
     * @notice Set signature threshold for term (admin only)
     * @param threshold Minimum signatures expected per term
     */
    function setSignatureThreshold(uint256 threshold) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        s.signatureThreshold = threshold;
    }

    /**
     * @notice Get signature threshold
     * @return threshold Current threshold
     */
    function getSignatureThreshold() external view returns (uint256) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.signatureThreshold;
    }

    /**
     * @notice Reset performance data for a signer (admin only)
     * @param signer Address of the signer
     */
    function resetSignerPerformance(address signer) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        delete s.signerPerformance[signer];
    }

    // Internal functions

    /**
     * @dev Update reliability score for a signer
     * Formula: (totalSignatures / (totalSignatures + missedSignatures)) * 100
     */
    function _updateReliabilityScore(address signer) internal {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        LibAppStorage.SignerPerformance storage perf = s.signerPerformance[signer];

        uint256 total = perf.totalSignatures + perf.missedSignatures;

        if (total == 0) {
            perf.reliabilityScore = 100; // Perfect score if no data yet
            return;
        }

        // Calculate score: (signatures / total) * 100
        uint256 score = (perf.totalSignatures * 100) / total;

        // Cap at 100
        if (score > 100) {
            score = 100;
        }

        perf.reliabilityScore = uint8(score);

        emit ReliabilityScoreUpdated(signer, perf.reliabilityScore, block.timestamp);
    }
}
