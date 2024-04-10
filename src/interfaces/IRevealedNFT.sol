// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IRevealedNFT is IERC721 {
    function initialize(string memory name_, string memory symbol_, address owner_) external;
    function mint(address to_, uint256 tokenId_, uint256 metadata_) external;
}
