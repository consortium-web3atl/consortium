pragma solidity ^0.8.18;

import "src/Revest_1155.sol";
import "src/Revest_721.sol";

contract Controller is Revest_721 {
     constructor(address weth, address _tokenVault, address _metadataHandler, address govController)
        Revest_721(weth, _tokenVault, _metadataHandler, govController)
    {}
}