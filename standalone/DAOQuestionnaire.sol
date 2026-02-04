// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title DAOQuestionnaire
 * @notice Standalone DAO Governance Questionnaire for Signer Elections
 * @dev Simplified version without Diamond Standard - ready to deploy today!
 *
 * Features:
 * - Candidate nominations
 * - 4-trait community assessment (100 points total)
 * - Median-based score aggregation
 * - Real-time leaderboard
 * - Phase management
 */
contract DAOQuestionnaire {

    // ============ Structs ============

    struct Nomination {
        uint256 id;
        address candidate;
        address nominator;
        string statement;
        uint256 timestamp;
        bool withdrawn;
    }

    struct Assessment {
        address assessor;
        uint8[4] traitScores; // [Technical, Reliability, Communication, Values]
        string feedback; // Max 69 characters
        uint256 timestamp;
    }

    struct AggregatedScores {
        uint8[4] medianScores;
        uint256 totalAssessments;
        uint256 lastUpdated;
    }

    // ============ State Variables ============

    address public owner;
    mapping(address => bool) public isAdmin;

    // Nomination data
    uint256 public nominationCounter;
    mapping(uint256 => Nomination) public nominations;
    mapping(address => uint256[]) public candidateNominations;
    mapping(address => bool) public isNominated;

    // Assessment data
    mapping(address => Assessment[]) public candidateAssessments;
    mapping(address => AggregatedScores) public aggregatedScores;
    mapping(address => mapping(address => bool)) public hasAssessed;
    uint256 public valuePointsPerAssessment = 100;

    // Phase control
    bool public nominationsOpen;
    bool public assessmentsOpen;
    uint256 public phaseStartTime;

    // ============ Events ============

    event CandidateNominated(
        uint256 indexed nominationId,
        address indexed candidate,
        address indexed nominator,
        string statement
    );

    event NominationWithdrawn(uint256 indexed nominationId, address indexed candidate);

    event CandidateAssessed(
        address indexed candidate,
        address indexed assessor,
        uint8[4] traitScores,
        string feedback
    );

    event PhaseChanged(string phase, bool isOpen);

    // ============ Modifiers ============

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || isAdmin[msg.sender], "Not authorized");
        _;
    }

    // ============ Constructor ============

    constructor() {
        owner = msg.sender;
    }

    // ============ Nomination Functions ============

    /**
     * @notice Nominate a candidate for signer role
     */
    function nominate(address candidate, string calldata statement) external returns (uint256) {
        require(nominationsOpen, "Nominations closed");
        require(candidate != address(0), "Invalid candidate");
        require(candidate != msg.sender, "Cannot nominate yourself");
        require(bytes(statement).length > 0 && bytes(statement).length <= 280, "Invalid statement length");

        nominationCounter++;
        uint256 nominationId = nominationCounter;

        nominations[nominationId] = Nomination({
            id: nominationId,
            candidate: candidate,
            nominator: msg.sender,
            statement: statement,
            timestamp: block.timestamp,
            withdrawn: false
        });

        candidateNominations[candidate].push(nominationId);
        isNominated[candidate] = true;

        emit CandidateNominated(nominationId, candidate, msg.sender, statement);

        return nominationId;
    }

    /**
     * @notice Withdraw your nomination
     */
    function withdrawNomination(uint256 nominationId) external {
        require(nominationId > 0 && nominationId <= nominationCounter, "Invalid ID");
        Nomination storage nomination = nominations[nominationId];
        require(nomination.nominator == msg.sender, "Not your nomination");
        require(!nomination.withdrawn, "Already withdrawn");

        nomination.withdrawn = true;
        emit NominationWithdrawn(nominationId, nomination.candidate);
    }

    /**
     * @notice Get all active nominations
     */
    function getActiveNominations() external view returns (Nomination[] memory) {
        uint256 activeCount = 0;

        // Count active
        for (uint256 i = 1; i <= nominationCounter; i++) {
            if (!nominations[i].withdrawn) {
                activeCount++;
            }
        }

        // Populate array
        Nomination[] memory activeNoms = new Nomination[](activeCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= nominationCounter; i++) {
            if (!nominations[i].withdrawn) {
                activeNoms[index] = nominations[i];
                index++;
            }
        }

        return activeNoms;
    }

    // ============ Assessment Functions ============

    /**
     * @notice Assess a candidate with 4-trait scores (must total 100)
     * @param candidate Address of candidate
     * @param traitScores [Technical, Reliability, Communication, Values]
     * @param feedback Optional feedback (max 69 chars)
     */
    function assessCandidate(
        address candidate,
        uint8[4] calldata traitScores,
        string calldata feedback
    ) external {
        require(assessmentsOpen, "Assessments closed");
        require(isNominated[candidate], "Not nominated");
        require(candidate != msg.sender, "Cannot assess yourself");
        require(!hasAssessed[msg.sender][candidate], "Already assessed");
        require(bytes(feedback).length <= 69, "Feedback too long");

        // Validate scores
        uint256 total = 0;
        for (uint256 i = 0; i < 4; i++) {
            require(traitScores[i] >= 5, "Minimum 5 per trait");
            total += traitScores[i];
        }
        require(total == valuePointsPerAssessment, "Must total 100 points");

        // Store assessment
        candidateAssessments[candidate].push(Assessment({
            assessor: msg.sender,
            traitScores: traitScores,
            feedback: feedback,
            timestamp: block.timestamp
        }));

        hasAssessed[msg.sender][candidate] = true;

        // Update aggregated scores
        _updateAggregatedScores(candidate);

        emit CandidateAssessed(candidate, msg.sender, traitScores, feedback);
    }

    /**
     * @notice Get all assessments for a candidate
     */
    function getCandidateAssessments(address candidate) external view returns (Assessment[] memory) {
        return candidateAssessments[candidate];
    }

    /**
     * @notice Get aggregated median scores for a candidate
     */
    function getAggregatedScores(address candidate) external view returns (uint8[4] memory) {
        return aggregatedScores[candidate].medianScores;
    }

    /**
     * @notice Get leaderboard of all candidates
     */
    function getLeaderboard() external view returns (
        address[] memory candidates,
        uint8[4][] memory scores,
        uint16[] memory totalScores
    ) {
        uint256 candidateCount = 0;
        for (uint256 i = 1; i <= nominationCounter; i++) {
            if (!nominations[i].withdrawn) {
                candidateCount++;
            }
        }

        candidates = new address[](candidateCount);
        scores = new uint8[4][](candidateCount);
        totalScores = new uint16[](candidateCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= nominationCounter; i++) {
            if (!nominations[i].withdrawn) {
                address candidate = nominations[i].candidate;
                candidates[index] = candidate;
                scores[index] = aggregatedScores[candidate].medianScores;

                uint16 total = 0;
                for (uint256 j = 0; j < 4; j++) {
                    total += scores[index][j];
                }
                totalScores[index] = total;
                index++;
            }
        }

        // Sort by total score (descending)
        for (uint256 i = 0; i < candidateCount; i++) {
            for (uint256 j = i + 1; j < candidateCount; j++) {
                if (totalScores[j] > totalScores[i]) {
                    (candidates[i], candidates[j]) = (candidates[j], candidates[i]);
                    (scores[i], scores[j]) = (scores[j], scores[i]);
                    (totalScores[i], totalScores[j]) = (totalScores[j], totalScores[i]);
                }
            }
        }

        return (candidates, scores, totalScores);
    }

    // ============ Admin Functions ============

    function setNominationPhase(bool isOpen) external onlyAdmin {
        nominationsOpen = isOpen;
        if (isOpen) phaseStartTime = block.timestamp;
        emit PhaseChanged("nominations", isOpen);
    }

    function setAssessmentPhase(bool isOpen) external onlyAdmin {
        assessmentsOpen = isOpen;
        emit PhaseChanged("assessments", isOpen);
    }

    function addAdmin(address admin) external onlyOwner {
        isAdmin[admin] = true;
    }

    function removeAdmin(address admin) external onlyOwner {
        isAdmin[admin] = false;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    // ============ Internal Functions ============

    function _updateAggregatedScores(address candidate) internal {
        Assessment[] storage assessments = candidateAssessments[candidate];
        uint256 count = assessments.length;

        if (count == 0) return;

        uint8[4] memory medians;

        for (uint256 trait = 0; trait < 4; trait++) {
            uint8[] memory scores = new uint8[](count);
            for (uint256 i = 0; i < count; i++) {
                scores[i] = assessments[i].traitScores[trait];
            }

            _quickSort(scores, 0, int256(count - 1));

            if (count % 2 == 0) {
                medians[trait] = uint8((uint256(scores[count / 2 - 1]) + uint256(scores[count / 2])) / 2);
            } else {
                medians[trait] = scores[count / 2];
            }
        }

        aggregatedScores[candidate] = AggregatedScores({
            medianScores: medians,
            totalAssessments: count,
            lastUpdated: block.timestamp
        });
    }

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
