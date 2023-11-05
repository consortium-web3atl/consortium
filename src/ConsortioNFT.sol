// SPDX-License-Identifier: GNU-GPL v3.0 or later

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title TokenVault
 * @author 0xTraub
 */
contract ConsortioNFT is ERC721 {
    constructor() ERC721("consortio_nft","cnft") {}
}