// SPDX-License-Identifier: GNU-GPL v3.0 or later

pragma solidity ^0.8.19;
pragma experimental ABIEncoderV2;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title TokenVault
 * @author 0xTraub
 */
contract Consortio is ReentrancyGuard {
   using SafeERC20 for IERC20;

    struct Pool {
        uint startTime;
        address[] entrants;
        
        uint epochLength;
        uint totalEpochs;
        // *monthly installment amount
        uint epochInstallment;
        address installmentToken;
        // entrants determine epochs
        // epoch lengths determine pool endTime
        mapping(address => mapping(uint => bool)) paidInstallment;
        mapping(uint => address) epochWinner;
        mapping(address => bool) fnftCollected;
    }
    mapping(uint => Pool) public pools;
    uint public poolId;

    // constructor - init first pool

    function currentEpoch(uint _poolId) public view returns (uint) {
        uint epoch;
        uint epochLength = pools[_poolId].epochLength;
        if (
            block.timestamp >= pools[_poolId].startTime +
                (epochLength * (pools[_poolId].totalEpochs - 1))
        ) {
            return pools[_poolId].totalEpochs;
        }

        // the first epoch's end time is the start time first epochLength
        uint endTime = pools[_poolId].startTime + epochLength;
        while (block.timestamp >= endTime) {
            endTime += epochLength;
            epoch++;
        }
        return epoch;
    }

    function createPool(
        uint _epochLength,
        uint _totalEpochs,
        uint _epochInstallment,
        address _installmentToken
    ) public {
        pools[poolId].startTime = block.timestamp;
        pools[poolId].epochLength = _epochLength;
        pools[poolId].totalEpochs = _totalEpochs;
        pools[poolId].epochInstallment = _epochInstallment;
        pools[poolId].installmentToken = _installmentToken;
        poolId++;
    }

    function enterPool(uint _poolId) external nonReentrant {
        require(pools[_poolId].entrants.length < pools[_poolId].totalEpochs, "We have reached max capacity");
        payInstallment(_poolId);
        pools[_poolId].entrants.push(msg.sender);
    }

    function payInstallment(uint _poolId) public {
        uint epoch = currentEpoch(_poolId);
        require(pools[_poolId].paidInstallment[msg.sender][epoch] != true, "Payments are current");
        IERC20(pools[_poolId].installmentToken).safeTransferFrom(
            msg.sender,
            address(this),
            pools[_poolId].epochInstallment
        );
        pools[_poolId].paidInstallment[msg.sender][epoch] = true;
    }

    function epochLottery(uint _poolId) public {
        uint epoch = currentEpoch(_poolId);
        for(uint i; i<pools[_poolId].entrants.length; i++) {
            address entrant = pools[_poolId].entrants[i];
            require(pools[_poolId].paidInstallment[entrant][epoch] == true, "Waiting on payments");
        }
        // todo: implement lottery functionality
        // This chooses the number but we must recall to get results
        // we must choose the winner by number, expose the winner, then allow them to collect
        // address epochWinner = pickWinner();

    }

    // implement diceRoll VRF
    function pickWinner() private returns (address){
        return address(this);
    }

    function collectFNFT() public {
        // if you are the epoch winnner and have not collected FNFT
        // VRF functionality explains who to return funds too
        // todo: wrap FNFT with pooled funds -- impovement would be to have seperate pool functions for reentrancy attacks
    }
}
