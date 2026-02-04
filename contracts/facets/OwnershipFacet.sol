// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {LibAppStorage} from "../libraries/LibAppStorage.sol";

/**
 * @title OwnershipFacet
 * @notice Manages ownership and admin access control
 * @dev Part of Diamond Standard DAO Governance Questionnaire System
 */
contract OwnershipFacet {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    /**
     * @notice Transfer ownership of the diamond
     * @param _newOwner New owner address
     */
    function transferOwnership(address _newOwner) external {
        LibDiamond.enforceIsContractOwner();
        require(_newOwner != address(0), "New owner cannot be zero address");

        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        address previousOwner = s.contractOwner;

        s.contractOwner = _newOwner;
        LibDiamond.setContractOwner(_newOwner);

        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    /**
     * @notice Get the current owner
     * @return owner The owner address
     */
    function owner() external view returns (address) {
        return LibDiamond.contractOwner();
    }

    /**
     * @notice Add an admin
     * @param admin Address to add as admin
     */
    function addAdmin(address admin) external {
        LibDiamond.enforceIsContractOwner();
        require(admin != address(0), "Admin cannot be zero address");

        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(!s.isAdmin[admin], "Already an admin");

        s.isAdmin[admin] = true;

        emit AdminAdded(admin);
    }

    /**
     * @notice Remove an admin
     * @param admin Address to remove from admins
     */
    function removeAdmin(address admin) external {
        LibDiamond.enforceIsContractOwner();

        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(s.isAdmin[admin], "Not an admin");

        s.isAdmin[admin] = false;

        emit AdminRemoved(admin);
    }

    /**
     * @notice Check if an address is an admin
     * @param account Address to check
     * @return isAdmin True if the address is an admin
     */
    function isAdmin(address account) external view returns (bool) {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        return s.isAdmin[account];
    }

    /**
     * @notice Batch add admins
     * @param admins Array of addresses to add as admins
     */
    function batchAddAdmins(address[] calldata admins) external {
        LibDiamond.enforceIsContractOwner();
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        for (uint256 i = 0; i < admins.length; i++) {
            address admin = admins[i];
            if (admin != address(0) && !s.isAdmin[admin]) {
                s.isAdmin[admin] = true;
                emit AdminAdded(admin);
            }
        }
    }
}
