// SPDX-License-Identifier: GNU-GPL v3.0 or later

pragma solidity ^0.8.19;
pragma experimental ABIEncoderV2;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/v0.8/vrf/VRFConsumerBaseV2.sol";
import "src/Revest_721.sol";
import "forge-std/console.sol";
import "src/interfaces/IController.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Consortio is ReentrancyGuard, VRFConsumerBaseV2, Ownable {
   using SafeERC20 for IERC20;

    // Deterministic addresses for deployment - Revest (see ../deployment_logs.txt)
    address tokenVault = 0xBd4DA114ac9117E131f101bB8eCd04dBA2aA52B4;
    address lockManager_timeLock = 0xF26a375FB3907e994D74A868f9212e0168B422E0;
    address lockManager_addressLock = 0x7543972Be5497AF54bab4fDe333Ffa53b5C52cF2;
    address metadataHandler = 0x3988f7CFb7baF15b24a62CA3F4336180cF5C1EBe;
    address revest721 = 0x5e55ceF07BB0ac38ca563f032eaBd780C00D5c4c;
    address fnftHandler = 0xdb00767B46650135D2854BBd4cbd502e6E397E84;
    address consortio_nft = 0x26a5BE39521F8e70fEfe14dB40043De82B5B7784;

    // VRF Integration
    mapping(uint256 => uint256) public requestIdToResult;
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    // Sepolia coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    Revest_721 private revest721Controller;
    
    event LotteryStarted(uint256 indexed requestId);
    event WinnerGenerated(uint256 indexed requestId, uint256 indexed result);

    constructor(uint64 subscriptionId, Revest_721 _revest721) VRFConsumerBaseV2(vrfCoordinator) Ownable(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        revest721Controller = _revest721;
    }

    struct Pool {
        uint startTime;
        address[] entrants;
        address[] remainingPlayers;
        
        uint epochLength;
        uint totalEpochs;
        // *monthly installment amount
        uint epochInstallment;
        address installmentToken;
        // entrants determine epochs
        // epoch lengths determine pool endTime
        mapping(address => mapping(uint => bool)) paidInstallment;
        mapping(uint => uint) epochRequestId;
        mapping(uint => address) epochWinner;
        // mapping(address => bool) fnftCollected;
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

        // Generate a pseudo-random number for testing purpose
    // by hashing the owner's address and the timestamp of the current block
    function getPseudoRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner(), block.timestamp)));
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
        require(currentEpoch(_poolId) == 0, "Already started");
        payInstallment(_poolId);
        pools[_poolId].entrants.push(msg.sender);
        pools[_poolId].remainingPlayers.push(msg.sender);
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
        _pickWinner();
    }

    function _pickWinner() internal {
        // todo: implement me
    }

    function collectFNFT(uint _poolId) public returns (address winner) {
        uint epoch = currentEpoch(_poolId);
        uint randomNum = requestIdToResult[pools[_poolId].epochRequestId[epoch]];

        // todo: if person wins - should be removed before next collection
        uint index = randomNum % pools[_poolId].remainingPlayers.length;
        address winner = pools[_poolId].remainingPlayers[index];
        pools[_poolId].remainingPlayers[index] = pools[_poolId].remainingPlayers[pools[_poolId].remainingPlayers.length - 1];
        pools[_poolId].remainingPlayers.pop();
        pools[_poolId].epochWinner[epoch] = winner;
        
        // todo: wrap FNFT with pooled funds -- impovement would be to have seperate pool functions for reentrancy attacks
        // ERC20.approve(revest, MAX_AMOUNT);
        IERC20 erc20 = IERC20(address(pools[_poolId].installmentToken));
        uint256 allPooledFunds = erc20.balanceOf(address(this));
        // approve Revest's controller to spend the ERC20 on behalf of pool
        erc20.approve(address(revest721Controller), type(uint256).max);
        erc20.safeTransfer(
            address(revest721Controller),
            allPooledFunds
        );
        // see example here: https://github.com/Revest-Finance/RevestV2-Public/blob/master/test/Revest721.t.sol#L194
        IController.FNFTConfig memory config = IController.FNFTConfig({
            handler: consortio_nft,
            asset: address(erc20),
            lockManager: lockManager_addressLock,
            nonce: 0,
            fnftId: 1,
            maturityExtension: false
        });
        address[] memory recipients = new address[](1);
        recipients[0] = winner;
        uint256[] memory amounts = new uint[](1);
        amounts[0] = 1;
        (uint id, bytes32 lockId) = revest721Controller.mintAddressLock("", recipients, amounts, allPooledFunds, config); // [1] vault
        console.log("fnftId %d", id);
        console.logBytes32(lockId);
    }

    /**
     * @notice Callback function used by VRF Coordinator to return the random number to this contract.
     *
     * @dev Some action on the contract state should be taken here, like storing the result.
     * @dev WARNING: take care to avoid having multiple VRF requests in flight if their order of arrival would result
     * in contract states with different outcomes. Otherwise miners or the VRF operator would could take advantage
     * by controlling the order.
     * @dev The VRF Coordinator will only send this function verified responses, and the parent VRFConsumerBaseV2
     * contract ensures that this method only receives randomness from the designated VRFCoordinator.
     *
     * @param requestId uint256
     * @param randomWords  uint256[] The random result returned by the oracle.
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 randomNumber = randomWords[0];
        requestIdToResult[requestId] = randomNumber;
        emit WinnerGenerated(requestId, randomNumber);
    }
}
