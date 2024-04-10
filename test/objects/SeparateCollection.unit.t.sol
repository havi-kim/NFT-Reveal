//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {SeparateCollection} from "src/objects/SeparateCollection.sol";
import {IRevealedNFT} from "src/interfaces/IRevealedNFT.sol";
import {RevealedNFT} from "src/RevealedNFT.sol";

// This is a test code wrapper for forge coverage issue(forge coverage miss library test codes).
contract WSeparateCollectionUnitTest {
    SeparateCollectionUnitTest private testTarget;

    function setUp() public {
        testTarget = new SeparateCollectionUnitTest();
    }

    // @success_test
    function test_createRevealedNFT() external {
        testTarget.$test_createRevealedNFT();
    }

    // @fail_test Case: Already created
    function test_createRevealedNFT_fail_already_created() external {
        testTarget.test_createRevealedNFT_fail_already_created();
    }

    // @success_test
    function test_mint() external {
        testTarget.test_mint();
    }
}

contract SeparateCollectionUnitTest is Test {
    // @succes_test
    function $test_createRevealedNFT() external {
        // Arrange
        string memory name = "TEST_NAME";
        string memory symbol = "TEST_SYMBOL";
        address owner = address(0x123);

        // Act
        SeparateCollection.createRevealedNFT(name, symbol, owner);

        // Assert
        IRevealedNFT revealedNFT = SeparateCollection.getRevealedNFT();
        assertEq(RevealedNFT(address(revealedNFT)).name(), name, "The name is not set correctly");
        assertEq(RevealedNFT(address(revealedNFT)).symbol(), symbol, "The symbol is not set correctly");
        assertEq(RevealedNFT(address(revealedNFT)).owner(), owner, "The owner is not set correctly");
    }

    // @fail_test Case: Already created
    function test_createRevealedNFT_fail_already_created() external {
        // Arrange
        string memory name = "TEST_NAME";
        string memory symbol = "TEST_SYMBOL";
        address owner = address(0x123);
        SeparateCollection.createRevealedNFT(name, symbol, owner);

        // Act
        vm.expectRevert("Reveal: Already created");
        SeparateCollection.createRevealedNFT(name, symbol, owner);
    }

    // @success_test
    function test_mint() external {
        // Arrange
        address to = address(0x1);
        uint256 tokenId = 10;
        uint256 metadata = uint256(0x300020001000a001400);
        SeparateCollection.createRevealedNFT("TEST_NAME", "TEST_SYMBOL", address(0x2));

        // Act
        SeparateCollection.mint(to, tokenId, metadata);

        // Assert
        IRevealedNFT revealedNFT = SeparateCollection.getRevealedNFT();
        assertEq(revealedNFT.ownerOf(tokenId), to, "Minted token is not owned by the correct address");
        assertEq(
            RevealedNFT(address(revealedNFT)).tokenURI(tokenId),
            '{"name": "The revealed NFT-10", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}'
        );
    }
}
