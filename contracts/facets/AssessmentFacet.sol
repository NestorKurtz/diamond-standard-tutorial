// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

/**
 * @title AssessmentFacet
 * @notice Handles community assessments of candidates using 4-trait scoring system
 * @dev Part of Diamond Standard DAO Governance Questionnaire System
 *
 * The 4 Traits (0-100 points each, must total 100 per candidate):
 * 1. Technical Competence
 * 2. Reliability & Commitment
 * 3. Communication & Transparency
 * 4. Alignment with DAO Values
 */
contract AssessmentFacet {
    event CandidateAssessed(
        address indexed candidate,
        address indexed assessor,
        uint8[4] traitScores,
        string feedback,
        uint256 timestamp
    );

    event AssessmentPhaseStatusChanged(bool isOpen);

    /**
     * @notice Assess a candidate with trait scores and optional feedback
     * @param candidate Address of the candidate being assessed
     * @param traitScores Array of 4 scores [Technical, Reliability, Communication, Values]
     * @param feedback Optional feedback (max 69 chars for brevity)
     */
    function assessCandidate(
        address candidate,
        uint8[4] calldata traitScores,
        string calldata feedback
    ) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        require(s.assessmentsOpen, "Assessments are currently closed");
        require(candidate != address(0), "Invalid candidate address");
        require(s.isNominated[candidate], "Candidate is not nominated");
        require(candidate != msg.sender, "Cannot assess yourself");
        require(!s.hasAssessed[msg.sender][candidate], "Already assessed this candidate");

        // Validate scores
        _validateTraitScores(traitScores);

        // Validate feedback length
        require(bytes(feedback).length <= 69, "Feedback too long (max 69 chars)");

        // Create assessment
        LibAppStorage.Assessment memory assessment = LibAppStorage.Assessment({
            assessor: msg.sender,
            candidate: candidate,
            traitScores: traitScores,
            feedback: feedback,
            timestamp: block.timestamp
        });

        s.candidateAssessments[candidate].push(assessment);
        s.hasAssessed[msg.sender][candidate] = true;

        // Update aggregated scores
        _updateAggregatedScores(candidate);

        emit CandidateAssessed(candidate, msg.sender, traitScores, feedback, block.timestamp);
    }

    /**
     * @notice Get aggregated median scores for a candidate
     * @param candidate Address of the candidate
     * @return medianScores Array of median scores for each trait
     */
    function getAggregatedScores(address candidate)
        external
        view
        returns (uint8[4] memory medianScores)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.aggregatedScores[candidate].medianScores;
    }

    /**
     * @notice Get full aggregated score details for a candidate
     * @param candidate Address of the candidate
     * @return scores The aggregated scores struct
     */
    function getAggregatedScoreDetails(address candidate)
        external
        view
        returns (LibAppStorage.AggregatedScores memory)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.aggregatedScores[candidate];
    }

    /**
     * @notice Get all assessments for a candidate
     * @param candidate Address of the candidate
     * @return assessments Array of all assessments
     */
    function getCandidateAssessments(address candidate)
        external
        view
        returns (LibAppStorage.Assessment[] memory)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.candidateAssessments[candidate];
    }

    /**
     * @notice Get the number of assessments for a candidate
     * @param candidate Address of the candidate
     * @return count Number of assessments
     */
    function getAssessmentCount(address candidate) external view returns (uint256) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.candidateAssessments[candidate].length;
    }

    /**
     * @notice Check if an assessor has already assessed a candidate
     * @param assessor Address of the assessor
     * @param candidate Address of the candidate
     * @return hasAssessed True if already assessed
     */
    function hasAssessedCandidate(address assessor, address candidate)
        external
        view
        returns (bool)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.hasAssessed[assessor][candidate];
    }

    /**
     * @notice Get leaderboard of all candidates with their scores
     * @return candidates Array of candidate addresses
     * @return scores Array of aggregated scores (parallel to candidates array)
     * @return totalScores Array of total scores (sum of median traits)
     */
    function getLeaderboard()
        external
        view
        returns (
            address[] memory candidates,
            uint8[4][] memory scores,
            uint16[] memory totalScores
        )
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        // Count nominated candidates
        uint256 candidateCount = 0;
        for (uint256 i = 1; i <= s.nominationCounter; i++) {
            if (!s.nominations[i].withdrawn) {
                candidateCount++;
            }
        }

        candidates = new address[](candidateCount);
        scores = new uint8[4][](candidateCount);
        totalScores = new uint16[](candidateCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= s.nominationCounter; i++) {
            if (!s.nominations[i].withdrawn) {
                address candidate = s.nominations[i].candidate;
                candidates[index] = candidate;
                scores[index] = s.aggregatedScores[candidate].medianScores;

                // Calculate total score
                uint16 total = 0;
                for (uint256 j = 0; j < 4; j++) {
                    total += scores[index][j];
                }
                totalScores[index] = total;
                index++;
            }
        }

        return (candidates, scores, totalScores);
    }

    // Admin functions

    /**
     * @notice Open or close assessments (admin only)
     * @param isOpen True to open assessments, false to close
     */
    function setAssessmentPhaseStatus(bool isOpen) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        s.assessmentsOpen = isOpen;

        emit AssessmentPhaseStatusChanged(isOpen);
    }

    /**
     * @notice Check if assessments are currently open
     * @return isOpen True if assessments are open
     */
    function areAssessmentsOpen() external view returns (bool) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.assessmentsOpen;
    }

    /**
     * @notice Set value points per assessment (admin only)
     * @param points New value (default: 100)
     */
    function setValuePointsPerAssessment(uint256 points) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");
        require(points > 0, "Points must be greater than 0");

        s.valuePointsPerAssessment = points;
    }

    // Internal functions

    /**
     * @dev Validate trait scores (must sum to valuePointsPerAssessment, min 5 per trait)
     */
    function _validateTraitScores(uint8[4] calldata traitScores) internal view {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        uint256 total = 0;
        for (uint256 i = 0; i < 4; i++) {
            require(traitScores[i] >= 5, "Minimum 5 points per trait");
            total += traitScores[i];
        }

        require(total == s.valuePointsPerAssessment, "Scores must total value points per assessment");
    }

    /**
     * @dev Update aggregated median scores for a candidate
     */
    function _updateAggregatedScores(address candidate) internal {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        LibAppStorage.Assessment[] storage assessments = s.candidateAssessments[candidate];
        uint256 count = assessments.length;

        if (count == 0) return;

        // Calculate median for each trait
        uint8[4] memory medians;

        for (uint256 trait = 0; trait < 4; trait++) {
            // Collect all scores for this trait
            uint8[] memory scores = new uint8[](count);
            for (uint256 i = 0; i < count; i++) {
                scores[i] = assessments[i].traitScores[trait];
            }

            // Sort and find median
            _quickSort(scores, 0, int256(count - 1));
            if (count % 2 == 0) {
                medians[trait] = uint8((uint256(scores[count / 2 - 1]) + uint256(scores[count / 2])) / 2);
            } else {
                medians[trait] = scores[count / 2];
            }
        }

        // Update aggregated scores
        s.aggregatedScores[candidate] = LibAppStorage.AggregatedScores({
            medianScores: medians,
            totalAssessments: count,
            lastUpdated: block.timestamp
        });
    }

    /**
     * @dev QuickSort algorithm for finding median
     */
    function _quickSort(uint8[] memory arr, int256 left, int256 right) internal pure {
        if (left >= right) return;

        int256 i = left;
        int256 j = right;
        uint8 pivot = arr[uint256(left + (right - left) / 2)];

        while (i <= j) {
            while (arr[uint256(i)] < pivot) i++;
            while (pivot < arr[uint256(j)]) j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)], arr[uint256(i)]);
                i++;
                j--;
            }
        }

        if (left < j) _quickSort(arr, left, j);
        if (i < right) _quickSort(arr, i, right);
    }
}
