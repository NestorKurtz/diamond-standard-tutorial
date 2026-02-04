// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

/**
 * @title NominationFacet
 * @notice Handles candidate nominations for DAO signer elections
 * @dev Part of Diamond Standard DAO Governance Questionnaire System
 */
contract NominationFacet {
    event CandidateNominated(
        uint256 indexed nominationId,
        address indexed candidate,
        address indexed nominator,
        string statement,
        uint256 timestamp
    );

    event NominationWithdrawn(
        uint256 indexed nominationId,
        address indexed candidate,
        uint256 timestamp
    );

    event NominationPhaseStatusChanged(bool isOpen);

    /**
     * @notice Nominate a candidate for signer role
     * @param candidate Address of the candidate being nominated
     * @param statement Nomination statement (can include IPFS hash for longer statements)
     * @return nominationId The ID of the created nomination
     */
    function nominate(address candidate, string calldata statement)
        external
        returns (uint256 nominationId)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        require(s.nominationsOpen, "Nominations are currently closed");
        require(candidate != address(0), "Invalid candidate address");
        require(candidate != msg.sender, "Cannot nominate yourself");
        require(bytes(statement).length > 0, "Statement cannot be empty");
        require(bytes(statement).length <= 280, "Statement too long (max 280 chars, use IPFS for longer)");

        // Increment counter and create nomination
        s.nominationCounter++;
        nominationId = s.nominationCounter;

        LibAppStorage.Nomination memory newNomination = LibAppStorage.Nomination({
            id: nominationId,
            candidate: candidate,
            nominator: msg.sender,
            statement: statement,
            timestamp: block.timestamp,
            withdrawn: false
        });

        s.nominations[nominationId] = newNomination;
        s.candidateNominations[candidate].push(nominationId);
        s.isNominated[candidate] = true;

        emit CandidateNominated(nominationId, candidate, msg.sender, statement, block.timestamp);

        return nominationId;
    }

    /**
     * @notice Withdraw a nomination (only by original nominator)
     * @param nominationId The ID of the nomination to withdraw
     */
    function withdrawNomination(uint256 nominationId) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        require(nominationId > 0 && nominationId <= s.nominationCounter, "Invalid nomination ID");

        LibAppStorage.Nomination storage nomination = s.nominations[nominationId];

        require(nomination.nominator == msg.sender, "Only nominator can withdraw");
        require(!nomination.withdrawn, "Nomination already withdrawn");

        nomination.withdrawn = true;

        emit NominationWithdrawn(nominationId, nomination.candidate, block.timestamp);
    }

    /**
     * @notice Get all nominations
     * @return allNominations Array of all nominations
     */
    function getNominations() external view returns (LibAppStorage.Nomination[] memory allNominations) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        uint256 totalNominations = s.nominationCounter;
        allNominations = new LibAppStorage.Nomination[](totalNominations);

        for (uint256 i = 1; i <= totalNominations; i++) {
            allNominations[i - 1] = s.nominations[i];
        }

        return allNominations;
    }

    /**
     * @notice Get active (non-withdrawn) nominations
     * @return activeNominations Array of active nominations
     */
    function getActiveNominations() external view returns (LibAppStorage.Nomination[] memory activeNominations) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        // First pass: count active nominations
        uint256 activeCount = 0;
        for (uint256 i = 1; i <= s.nominationCounter; i++) {
            if (!s.nominations[i].withdrawn) {
                activeCount++;
            }
        }

        // Second pass: populate array
        activeNominations = new LibAppStorage.Nomination[](activeCount);
        uint256 currentIndex = 0;
        for (uint256 i = 1; i <= s.nominationCounter; i++) {
            if (!s.nominations[i].withdrawn) {
                activeNominations[currentIndex] = s.nominations[i];
                currentIndex++;
            }
        }

        return activeNominations;
    }

    /**
     * @notice Get nominations for a specific candidate
     * @param candidate Address of the candidate
     * @return candidateNoms Array of nomination IDs for the candidate
     */
    function getNominationsForCandidate(address candidate)
        external
        view
        returns (uint256[] memory)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.candidateNominations[candidate];
    }

    /**
     * @notice Get a specific nomination by ID
     * @param nominationId The ID of the nomination
     * @return nomination The nomination details
     */
    function getNomination(uint256 nominationId)
        external
        view
        returns (LibAppStorage.Nomination memory)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(nominationId > 0 && nominationId <= s.nominationCounter, "Invalid nomination ID");
        return s.nominations[nominationId];
    }

    /**
     * @notice Check if address is currently nominated
     * @param candidate Address to check
     * @return isNominated True if the address has an active nomination
     */
    function isCandidateNominated(address candidate) external view returns (bool) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.isNominated[candidate];
    }

    /**
     * @notice Get total nomination count
     * @return count Total number of nominations
     */
    function getNominationCount() external view returns (uint256) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.nominationCounter;
    }

    // Admin functions

    /**
     * @notice Open or close nominations (admin only)
     * @param isOpen True to open nominations, false to close
     */
    function setNominationPhaseStatus(bool isOpen) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        s.nominationsOpen = isOpen;
        if (isOpen) {
            s.phaseStartTime = block.timestamp;
        }

        emit NominationPhaseStatusChanged(isOpen);
    }

    /**
     * @notice Check if nominations are currently open
     * @return isOpen True if nominations are open
     */
    function areNominationsOpen() external view returns (bool) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.nominationsOpen;
    }
}
