// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/vrf/VRFCoordinatorV2Interface.sol";

import "../src/NFT.sol";

contract NFTUnitTest is Test {
    NFT private testTarget;
    address private mockCoordinator = address(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
    uint96 private mintPrice = 0.1 ether;

    function setUp() public {
        testTarget = new NFT();
        testTarget.initialize("TEST_NAME", "TEST_SYMBOL", mockCoordinator, mintPrice, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 10));
    }

    // @success_test
    function test_mint() external {
        // Arrange
        vm.roll(block.number + 1);
        uint balanceOfThis = address(this).balance;
        uint balanceOfTarget = address(testTarget).balance;

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
        uint balanceOfThis = address(this).balance;
        uint balanceOfTarget = address(testTarget).balance;

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
        vm.expectRevert("mint: Minting has not started yet");
        testTarget.mint();
    }

    // @fail_test Case: Reveal has already started
    function test_mint_fail_after_reveal_start() external {
        // Arrange
        vm.roll(block.number + 10);

        // Act
        vm.expectRevert("mint: Reveal has already started");
        testTarget.mint();
    }

    // @fail_test Case: Insufficient payment
    function test_mint_fail_insufficient_payment() external {
        // Arrange
        vm.roll(block.number + 1);

        // Act
        vm.expectRevert("mint: Insufficient payment");
        testTarget.mint{value: mintPrice - 1}();
    }

    // @success_test
    function test_reveal() external {
        // Arrange
        uint256 requestId = 5;
        vm.roll(block.number + 1);
        uint tokenId = testTarget.mint{value: mintPrice}();

        vm.roll(block.number + 10);

        // Act
        vm.mockCall(mockCoordinator, abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector), abi.encode(requestId));
        uint256 returnId = testTarget.reveal(tokenId);

        // Assert
        assertEq(returnId, requestId, "The return value is not correct");
    }

    // @fail_test Case: Reveal has not started yet
    function test_reveal_fail_reveal_not_start() external {
        // Arrange
        uint256 requestId = 5;
        vm.roll(block.number + 1);
        uint tokenId = testTarget.mint{value: mintPrice}();

        // Act
        vm.expectRevert("reveal: Reveal has not started yet");
        vm.mockCall(mockCoordinator, abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector), abi.encode(requestId));
        testTarget.reveal(tokenId);
    }

    // @success_test
    function test_withdraw() external {
        // Arrange
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();
        uint balanceOfThis = address(this).balance;
        uint balanceOfTarget = address(testTarget).balance;
        uint testAmount = 0.001e18;

        // Act
        testTarget.withdraw(testAmount);

        // Assert
        assertEq(address(this).balance, balanceOfThis + testAmount, "The balance of this address is not increased");
        assertEq(address(testTarget).balance, balanceOfTarget - testAmount, "The balance of target address is not decreased");
    }

    // @success_test
    function test_withdraw_over_balance() external {
        // Arrange
        vm.roll(block.number + 1);
        uint256 tokenId = testTarget.mint{value: mintPrice}();
        uint balanceOfThis = address(this).balance;
        uint balanceOfTarget = address(testTarget).balance;
        uint testAmount = balanceOfTarget + 0.001e18;

        // Act
        testTarget.withdraw(testAmount);

        // Assert
        assertEq(address(this).balance, balanceOfThis + balanceOfTarget, "The balance of this address is not increased");
        assertEq(address(testTarget).balance, 0, "The balance of target is invalid");
    }

    receive() external payable {}
}
