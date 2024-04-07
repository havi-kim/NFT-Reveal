//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {Metadata} from "src/objects/Metadata.sol";

// This is a test code wrapper for forge coverage issue(forge coverage miss library test codes).
contract WMetadataUnitTest {
    MetadataUnitTest private testTarget;

    function setUp() public {
        testTarget = new MetadataUnitTest();
    }

    // @succes_test
    function test_setMetadata() external {
        testTarget.$test_setMetadata();
    }

    // @fail_test
    function test_setMetadata_fail() external {
        testTarget.$test_setMetadata_fail();
    }

    // @succes_test
    function test_getMetadata() external {
        testTarget.$test_getMetadata();
    }
}

contract MetadataUnitTest is Test {
    // @succes_test
    function $test_setMetadata() external {
        // Arrange
        uint256 tokenId = 1;
        uint256 metadata = uint256(0x300020001000a001400);

        // Act
        Metadata.setMetadata(tokenId, metadata);

        // Assert
        string memory result = Metadata.getMetadata(tokenId);
        assertEq(result, '{"name": "The revealed NFT-1", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}');
    }

    // @fail_test
    function $test_setMetadata_fail() external {
        // Arrange
        uint256 tokenId = 1;
        uint256 metadata = uint256(0x300020001000a001400);
        Metadata.setMetadata(tokenId, metadata);

        // Act
        vm.expectRevert("setMetadata: Already set");
        Metadata.setMetadata(tokenId, metadata);
    }

    // @succes_test
    function $test_getMetadata() external {
        // Arrange
        uint256 tokenId = 1;

        // Act
        string memory result = Metadata.getMetadata(tokenId);

        // Assert
        assertEq(result, '{"name": "Unrevealed NFT", "description": "This is a unrevealed NFT."}');
    }
}
