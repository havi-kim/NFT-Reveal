// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/RevealedNFT.sol";

contract RevealedNFTUnitTest is Test {
    RevealedNFT private testTarget;

    function setUp() public {
        testTarget = new RevealedNFT();
    }

    // @success_test
    function test_mint() external {
        // Arrange
        address to = address(0x1);
        uint256 tokenId = 2;
        uint256 metadata = uint256(0x300020001000a001400);
        testTarget.initialize("TEST_NAME", "TEST_SYMBOL", address(0x2));

        // Act
        testTarget.mint(to, tokenId, metadata);

        // Assert
        string memory result = testTarget.tokenURI(tokenId);
        assertEq(testTarget.ownerOf(tokenId), to, "Minted token is not owned by the correct address");
        assertEq(
            result,
            '{"name": "The revealed NFT-2", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}'
        );
    }

    // @fail_test Case: Call from other account
    function test_mint_fail_from_other() external {
        // Arrange
        address to = address(0x1);
        uint256 tokenId = 2;
        uint256 metadata = uint256(0x300020001000a001400);
        RevealedNFT revealedNFT = new RevealedNFT();
        revealedNFT.initialize("TEST_NAME", "TEST_SYMBOL", address(0x2));

        // Act
        vm.broadcast(address(0x3)); // Set msg.sender to a different address
        vm.expectRevert(abi.encodeWithSelector(RevealedNFTError.OnlyParentNFT.selector, address(this), address(0x3)));
        revealedNFT.mint(to, tokenId, metadata);
    }
}
