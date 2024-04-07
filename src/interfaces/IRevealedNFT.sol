// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IRevealedNFT {
    function initialize(string memory name_, string memory symbol_, address owner_) external;
    function mint(address to_, uint256 tokenId_) external;
}
