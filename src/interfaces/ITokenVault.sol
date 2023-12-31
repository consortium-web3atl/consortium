// SPDX-License-Identifier: GNU-GPL v3.0 or later

pragma solidity ^0.8.19;

import "./IRevest.sol";

interface ITokenVault {
    /// Emitted when an FNFT is withdraw  to denote what tokens have been withdrawn
    event WithdrawERC20(address token, address indexed user, bytes32 indexed salt, uint256 amount, address smartWallet);

    function invokeSmartWallet(bytes32 salt, bytes4 selector, bytes calldata data) external;

    function getAddress(bytes32 salt, address caller) external view returns (address smartWallet);

    function proxyCall(bytes32 salt, address[] memory targets, uint256[] memory values, bytes[] memory calldatas)
        external
        returns (bytes[] memory outputs);
}
