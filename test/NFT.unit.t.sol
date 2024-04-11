// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/vrf/VRFCoordinatorV2Interface.sol";

import "src/NFT.sol";
import "src/RevealedNFT.sol";

contract NFTUnitTest is Test {
    NFT private testTarget;
    address private mockCoordinator = address(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
    uint96 private mintPrice = 0.1 ether;

    function setUp() public {
        testTarget = new NFT();
        testTarget.initialize(
            "TEST_NAME",
            "TEST_SYMBOL",
            mockCoordinator,
            mintPrice,
            uint48(block.number + 1),
            RevealType.InCollection,
            uint48(block.number + 10)
        );
    }

    // @success_test
    function test_mint() external {
        // Arrange
        vm.roll(block.number + 1);
        uint256 balanceOfThis = address(this).balance;
        uint256 balanceOfTarget = address(testTarget).balance;

        // Act
        uint256 tokenId = testTarget.mint{value: mintPrice}();

        // Assert
        assertEq(testTarget.ownerOf(tokenId), address(this), "Minted token is not owned by the correct address");
        assertEq(address(this).balance, balanceOfThis - mintPrice, "The surplus is not refunded");
        assertEq(address(testTarget).balance, balanceOfTarget + mintPrice, "The mint price is not deposited");
    }

    // @success_test
    function test_mint_pay_over() external {
        // Arrange
        vm.roll(block.number + 1);
        uint256 balanceOfThis = address(this).balance;
        uint256 balanceOfTarget = address(testTarget).balance;

        // Act
        uint256 tokenId = testTarget.mint{value: mintPrice + 1e18}();

        // Assert
        assertEq(testTarget.ownerOf(tokenId), address(this), "Minted token is not owned by the correct address");
        assertEq(address(this).balance, balanceOfThis - mintPrice, "The surplus is not refunded");
        assertEq(address(testTarget).balance, balanceOfTarget + mintPrice, "The mint price is not deposited");
    }

    // @fail_test Case: minting has not started yet
    function test_mint_fail_minting_not_start() external {
        // Act
        vm.expectRevert(ConfigError.MintingHasNotStarted.selector);
        testTarget.mint();
    }

    // @fail_test Case: Reveal has already started
    function test_mint_fail_after_reveal_start() external {
        // Arrange
        vm.roll(block.number + 10);

        // Act
        vm.expectRevert(ConfigError.RevealAlreadyStarted.selector);
        testTarget.mint();
    }

    // @fail_test Case: Insufficient payment
    function test_mint_fail_insufficient_payment() external {
        // Arrange
        vm.roll(block.number + 1);

        // Act
        vm.expectRevert(abi.encodeWithSelector(ConfigError.InsufficientPayment.selector, mintPrice, mintPrice - 1));
        testTarget.mint{value: mintPrice - 1}();
    }

    // @success_test
    function test_reveal() external {
        // Arrange
        uint256 requestId = 5;
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();

        vm.roll(block.number + 10);

        // Act
        vm.mockCall(
            mockCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(requestId)
        );
        uint256 returnId = testTarget.reveal(tokenId);

        // Assert
        assertEq(returnId, requestId, "The return value is not correct");
    }

    // @fail_test Case: Reveal has not started yet
    function test_reveal_fail_reveal_not_start() external {
        // Arrange
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();

        // Act
        vm.expectRevert(ConfigError.RevealHasNotStarted.selector);
        testTarget.reveal(tokenId);
    }

    // @success_test
    function test_reveal_with_createRevealedNFT() external {
        // Arrange
        testTarget.setRevealType(RevealType.SeparateCollection);
        uint256 requestId = 5;
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();
        address revealedNFT = testTarget.revealedNFT();

        vm.roll(block.number + 10);

        // Act
        vm.mockCall(
            mockCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(requestId)
        );
        uint256 returnId = testTarget.reveal(tokenId);

        // Assert
        assertEq(returnId, requestId, "The return value is not correct");
        assertTrue(revealedNFT == address(0), "The revealed NFT is already created");
        assertTrue(testTarget.revealedNFT() != revealedNFT, "The revealed NFT is not created");
    }

    // @success_test Case: InCollection
    function test_fulfillRandomWords_InCollection() external {
        // Arrange
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();
        uint256 requestId = 5;
        vm.mockCall(
            mockCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(requestId)
        );
        vm.roll(block.number + 10);
        testTarget.reveal(tokenId);
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = uint256(0x300020001000a001400);

        // Act
        vm.broadcast(mockCoordinator);
        testTarget.rawFulfillRandomWords(requestId, randomWords); // This function cover the fulfillRandomWords function

        // Assert
        assertEq(
            testTarget.tokenURI(tokenId),
            '{"name": "The revealed NFT-1", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}',
            "The token URI is not set correctly"
        );
    }

    // @success_test Case: SeparateCollection
    function test_fulfillRandomWords_SeparateCollection() external {
        // Arrange
        testTarget.setRevealType(RevealType.SeparateCollection);
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();
        uint256 requestId = 5;
        vm.mockCall(
            mockCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(requestId)
        );
        vm.roll(block.number + 10);
        testTarget.reveal(tokenId);
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = uint256(0x300020001000a001400);

        // Act
        vm.broadcast(mockCoordinator);
        testTarget.rawFulfillRandomWords(requestId, randomWords); // This function cover the fulfillRandomWords function

        // Assert
        assertEq(
            RevealedNFT(testTarget.revealedNFT()).tokenURI(tokenId),
            '{"name": "The revealed NFT-1", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}',
            "The token URI is not set correctly"
        );
        assertEq(
            RevealedNFT(testTarget.revealedNFT()).ownerOf(tokenId),
            address(this),
            "The owner of revealed NFT is not minted"
        );
        vm.expectRevert();
        testTarget.ownerOf(tokenId); // Original NFT burn check
    }

    // @fail_test Case: Invalid reveal type
    function test_fulfillRandomWords_fail_invalid_reveal_type() external {
        // Arrange
        testTarget.setRevealType(RevealType.None);
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();
        uint256 requestId = 5;
        vm.mockCall(
            mockCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(requestId)
        );
        vm.roll(block.number + 10);
        testTarget.reveal(tokenId);
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = uint256(0x300020001000a001400);

        // Act
        vm.expectRevert(abi.encodeWithSelector(CollectionError.InvalidCollectionType.selector, RevealType.None));
        vm.broadcast(mockCoordinator);
        testTarget.rawFulfillRandomWords(requestId, randomWords); // This function cover the fulfillRandomWords function
    }

    // @success_test
    function test_createRevealedNFT() external {
        // Arrange
        testTarget.setRevealType(RevealType.SeparateCollection);

        // Act
        testTarget.createRevealedNFT();

        // Assert
        assertEq(RevealedNFT(testTarget.revealedNFT()).name(), "TEST_NAME", "The name is not set correctly");
        assertEq(RevealedNFT(testTarget.revealedNFT()).symbol(), "TEST_SYMBOL", "The symbol is not set correctly");
        assertEq(RevealedNFT(testTarget.revealedNFT()).owner(), address(this), "The owner is not set correctly");
    }

    // @fail_test Case: Not separate collection
    function test_createRevealedNFT_fail_not_separate_collection() external {
        // Arrange
        testTarget.setRevealType(RevealType.InCollection);

        // Act
        vm.expectRevert(ConfigError.OnlySeparateCollectionType.selector);
        testTarget.createRevealedNFT();
    }

    // @success_test
    function test_withdraw() external {
        // Arrange
        vm.roll(block.number + 1);
        testTarget.mint{value: mintPrice}();
        uint256 balanceOfThis = address(this).balance;
        uint256 balanceOfTarget = address(testTarget).balance;
        uint256 testAmount = 0.001e18;

        // Act
        testTarget.withdraw(testAmount);

        // Assert
        assertEq(address(this).balance, balanceOfThis + testAmount, "The balance of this address is not increased");
        assertEq(
            address(testTarget).balance, balanceOfTarget - testAmount, "The balance of target address is not decreased"
        );
    }

    // @success_test
    function test_withdraw_over_balance() external {
        // Arrange
        vm.roll(block.number + 1);
        testTarget.mint{value: mintPrice}();
        uint256 balanceOfThis = address(this).balance;
        uint256 balanceOfTarget = address(testTarget).balance;
        uint256 testAmount = balanceOfTarget + 0.001e18;

        // Act
        testTarget.withdraw(testAmount);

        // Assert
        assertEq(address(this).balance, balanceOfThis + balanceOfTarget, "The balance of this address is not increased");
        assertEq(address(testTarget).balance, 0, "The balance of target is invalid");
    }

    // @fail_test Case: Not owner
    function test_withdraw_fail_not_owner() external {
        // Arrange
        vm.roll(block.number + 1);
        testTarget.mint{value: mintPrice}();
        uint256 testAmount = 0.001e18;

        // Act
        vm.broadcast(address(0x1));
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(0x1)));
        testTarget.withdraw(testAmount);
    }

    // @success_test
    function test_setMintPrice() external {
        // Arrange
        uint96 newPrice = 0.2 ether;

        // Act
        testTarget.setMintPrice(newPrice);

        // Assert
        assertEq(testTarget.config().mintPrice, newPrice, "The mint price is not set correctly");
    }

    // @fail_test Case: Not owner
    function test_setMintPrice_fail_not_owner() external {
        // Arrange
        uint96 newPrice = 0.2 ether;

        // Act
        vm.broadcast(address(0x1));
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(0x1)));
        testTarget.setMintPrice(newPrice);
    }

    // @success_test
    function test_setMintStartBlock() external {
        // Arrange
        uint48 newBlock = uint48(block.number + 5);

        // Act
        testTarget.setMintStartBlock(newBlock);

        // Assert
        assertEq(testTarget.config().mintStartBlock, newBlock, "The mint start block is not set correctly");
    }

    // @fail_test Case: Not owner
    function test_setMintStartBlock_fail_not_owner() external {
        // Arrange
        uint48 newBlock = uint48(block.number + 5);

        // Act
        vm.broadcast(address(0x1));
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(0x1)));
        testTarget.setMintStartBlock(newBlock);
    }

    // @success_test
    function test_setRevealType() external {
        // Arrange
        RevealType newType = RevealType.SeparateCollection;

        // Act
        testTarget.setRevealType(newType);

        // Assert
        assertTrue(testTarget.config().revealType == newType, "The reveal type is not set correctly");
    }

    // @fail_test Case: Not owner
    function test_setRevealType_fail_not_owner() external {
        // Arrange
        RevealType newType = RevealType.SeparateCollection;

        // Act
        vm.broadcast(address(0x1));
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(0x1)));
        testTarget.setRevealType(newType);
    }

    // @success_test
    function test_setRevealStartBlock() external {
        // Arrange
        uint48 newBlock = uint48(block.number + 10);

        // Act
        testTarget.setRevealStartBlock(newBlock);

        // Assert
        assertEq(testTarget.config().revealStartBlock, newBlock, "The reveal start block is not set correctly");
    }

    // @fail_test Case: Not owner
    function test_setRevealStartBlock_fail_not_owner() external {
        // Arrange
        uint48 newBlock = uint48(block.number + 10);

        // Act
        vm.broadcast(address(0x1));
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(0x1)));
        testTarget.setRevealStartBlock(newBlock);
    }

    receive() external payable {}
}
