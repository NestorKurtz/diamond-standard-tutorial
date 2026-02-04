// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

/**
 * @title AvailabilityFacet
 * @notice Handles signer availability status signaling
 * @dev Part of Diamond Standard DAO Governance Questionnaire System
 */
contract AvailabilityFacet {
    event SignerStatusUpdated(
        address indexed signer,
        LibAppStorage.SignerStatus previousStatus,
        LibAppStorage.SignerStatus newStatus,
        uint256 timestamp
    );

    event SignerAdded(address indexed signer, uint256 timestamp);
    event SignerRemoved(address indexed signer, uint256 timestamp);

    /**
     * @notice Update signer availability status
     * @param newStatus New status (Active, OnLeave, Inactive)
     * @dev Can only be called by authorized signers
     */
    function updateStatus(LibAppStorage.SignerStatus newStatus) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        require(
            s.signerStatus[msg.sender] != LibAppStorage.SignerStatus.Inactive ||
            s.isAdmin[msg.sender] ||
            msg.sender == s.contractOwner,
            "Not an authorized signer"
        );

        require(newStatus != LibAppStorage.SignerStatus.Removed, "Cannot self-remove");

        LibAppStorage.SignerStatus previousStatus = s.signerStatus[msg.sender];
        s.signerStatus[msg.sender] = newStatus;

        // Update active signers list
        if (newStatus == LibAppStorage.SignerStatus.Active && previousStatus != LibAppStorage.SignerStatus.Active) {
            _addToActiveSigners(msg.sender);
        } else if (newStatus != LibAppStorage.SignerStatus.Active && previousStatus == LibAppStorage.SignerStatus.Active) {
            _removeFromActiveSigners(msg.sender);
        }

        emit SignerStatusUpdated(msg.sender, previousStatus, newStatus, block.timestamp);
    }

    /**
     * @notice Get signer status
     * @param signer Address of the signer
     * @return status Current status of the signer
     */
    function getSignerStatus(address signer)
        external
        view
        returns (LibAppStorage.SignerStatus)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.signerStatus[signer];
    }

    /**
     * @notice Get all active signers
     * @return signers Array of active signer addresses
     */
    function getActiveSigners() external view returns (address[] memory) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.activeSigners;
    }

    /**
     * @notice Get count of active signers
     * @return count Number of active signers
     */
    function getActiveSignerCount() external view returns (uint256) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.activeSigners.length;
    }

    /**
     * @notice Get signer join timestamp
     * @param signer Address of the signer
     * @return timestamp When the signer was added
     */
    function getSignerJoinedTimestamp(address signer)
        external
        view
        returns (uint256)
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.signerJoinedTimestamp[signer];
    }

    /**
     * @notice Check if address is an active signer
     * @param signer Address to check
     * @return isActive True if signer is active
     */
    function isActiveSigner(address signer) external view returns (bool) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.signerStatus[signer] == LibAppStorage.SignerStatus.Active;
    }

    /**
     * @notice Get comprehensive status of all signers
     * @return signers Array of signer addresses
     * @return statuses Array of statuses (parallel to signers)
     * @return joinTimestamps Array of join timestamps
     */
    function getAllSignerStatuses()
        external
        view
        returns (
            address[] memory signers,
            LibAppStorage.SignerStatus[] memory statuses,
            uint256[] memory joinTimestamps
        )
    {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        // Count total signers (everyone who has ever had a status)
        uint256 signerCount = s.activeSigners.length;

        signers = new address[](signerCount);
        statuses = new LibAppStorage.SignerStatus[](signerCount);
        joinTimestamps = new uint256[](signerCount);

        for (uint256 i = 0; i < signerCount; i++) {
            address signer = s.activeSigners[i];
            signers[i] = signer;
            statuses[i] = s.signerStatus[signer];
            joinTimestamps[i] = s.signerJoinedTimestamp[signer];
        }

        return (signers, statuses, joinTimestamps);
    }

    // Admin functions

    /**
     * @notice Add a new signer (admin only)
     * @param signer Address of the new signer
     */
    function addSigner(address signer) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");
        require(signer != address(0), "Invalid signer address");
        require(
            s.signerStatus[signer] == LibAppStorage.SignerStatus.Inactive,
            "Signer already exists"
        );

        s.signerStatus[signer] = LibAppStorage.SignerStatus.Active;
        s.signerJoinedTimestamp[signer] = block.timestamp;
        _addToActiveSigners(signer);

        emit SignerAdded(signer, block.timestamp);
    }

    /**
     * @notice Remove a signer (admin only)
     * @param signer Address of the signer to remove
     */
    function removeSigner(address signer) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        LibAppStorage.SignerStatus previousStatus = s.signerStatus[signer];
        require(previousStatus != LibAppStorage.SignerStatus.Removed, "Signer already removed");

        s.signerStatus[signer] = LibAppStorage.SignerStatus.Removed;
        _removeFromActiveSigners(signer);

        emit SignerRemoved(signer, block.timestamp);
    }

    /**
     * @notice Batch add signers (admin only)
     * @param signers Array of signer addresses to add
     */
    function batchAddSigners(address[] calldata signers) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.contractOwner || s.isAdmin[msg.sender], "Not authorized");

        for (uint256 i = 0; i < signers.length; i++) {
            address signer = signers[i];
            if (
                signer != address(0) &&
                s.signerStatus[signer] == LibAppStorage.SignerStatus.Inactive
            ) {
                s.signerStatus[signer] = LibAppStorage.SignerStatus.Active;
                s.signerJoinedTimestamp[signer] = block.timestamp;
                _addToActiveSigners(signer);
                emit SignerAdded(signer, block.timestamp);
            }
        }
    }

    // Internal functions

    /**
     * @dev Add signer to active signers list
     */
    function _addToActiveSigners(address signer) internal {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        // Check if already in active list
        for (uint256 i = 0; i < s.activeSigners.length; i++) {
            if (s.activeSigners[i] == signer) {
                return;
            }
        }

        s.activeSigners.push(signer);
    }

    /**
     * @dev Remove signer from active signers list
     */
    function _removeFromActiveSigners(address signer) internal {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        for (uint256 i = 0; i < s.activeSigners.length; i++) {
            if (s.activeSigners[i] == signer) {
                // Replace with last element and pop
                s.activeSigners[i] = s.activeSigners[s.activeSigners.length - 1];
                s.activeSigners.pop();
                return;
            }
        }
    }
}
