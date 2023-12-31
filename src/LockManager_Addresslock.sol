// SPDX-License-Identifier: GNU-GPL v3.0 or later

pragma solidity ^0.8.19;

import "./LockManager_Base.sol";
import "forge-std/console.sol";

/**
 * @title LockManager_Addresslock
 * @author 0xTraub
 */
contract LockManager_Addresslock is LockManager_Base {
    ILockManager.LockType public constant override lockType = ILockManager.LockType.AddressLock;

    constructor() LockManager_Base() {}

    function createLock(bytes32 salt, bytes calldata) external override nonReentrant returns (bytes32 lockId) {
        console.log("entered create lock addresslock");
        lockId = keccak256(abi.encode(salt, msg.sender));

        // Extensive validation on creation
        ILockManager.Lock memory newLock;

        newLock.creationTime = uint96(block.timestamp);

        //Use a single SSTORE
        locks[lockId] = newLock;
    }

    function extendLockMaturity(bytes32, bytes calldata) external {}

    /**
     * Return whether a lock of any type is mature. Use this for all locktypes.
     */
    function getLockMaturity(bytes32, uint256) public view override returns (bool hasMatured) {
        //Note: Can be replaced with any logic you want I just have this for the tests
        return (block.timestamp % 2 == 0);
    }
}
