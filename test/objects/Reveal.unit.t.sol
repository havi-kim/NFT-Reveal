//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {Reveal} from "src/objects/Reveal.sol";
import {RevealError} from "src/errors/Error.sol";
import {RevealStatus} from "src/types/GlobalEnum.sol";

// This is a test code wrapper for forge coverage issue(forge coverage miss library test codes).
contract WRevealUnitTest {
    RevealUnitTest private testTarget;

    function setUp() public {
        testTarget = new RevealUnitTest();
    }

    // @succes_test
    function test_startReveal() external {
        testTarget.$test_startReveal();
    }

    // @fail_test
    function test_startReveal_fail() external {
        testTarget.$test_startReveal_fail_already_started();
    }

    // @succes_test
    function test_endReveal() external {
        testTarget.$test_endReveal();
    }

    // @fail_test
    function test_endReveal_fail() external {
        testTarget.$test_endReveal_fail_not_in_progress();
    }
}

contract RevealUnitTest is Test {
    // @succes_test
    function $test_startReveal() external {
        // Arrange
        uint256 tokenId = 1;
        uint256 requestId = 2;

        // Act
        Reveal.startReveal(tokenId, requestId);

        // Assert
        (address to, uint256 queriedTokenId) = Reveal.request(requestId);
        assertTrue(to == msg.sender, "The address of the receiver is not correct");
        assertTrue(queriedTokenId == tokenId, "The token ID is not correct");
        assertTrue(Reveal.status(tokenId) == RevealStatus.InProgress, "The reveal status is not in progress");
    }

    // @fail_test Case: the reveal process is already started
    function $test_startReveal_fail_already_started() external {
        // Arrange
        uint256 tokenId = 1;
        uint256 requestId = 2;
        Reveal.startReveal(tokenId, requestId);

        // Act & Assert
        vm.expectRevert(abi.encodeWithSelector(RevealError.RevealProcessAlreadyStarted.selector, tokenId));
        Reveal.startReveal(tokenId, requestId);
    }

    // @success_test
    function $test_endReveal() external {
        // Arrange
        uint256 tokenId = 1;
        uint256 requestId = 2;
        Reveal.startReveal(tokenId, requestId);

        // Act
        (uint256 queriedTokenId, address to) = Reveal.endReveal(requestId);

        // Assert
        assertTrue(to == msg.sender, "The address of the receiver is not correct");
        assertTrue(queriedTokenId == tokenId, "The token ID is not correct");
        assertTrue(Reveal.status(tokenId) == RevealStatus.Revealed, "The reveal status is not revealed");
    }

    // @fail_test Case: the reveal process is not in progress
    function $test_endReveal_fail_not_in_progress() external {
        // Arrange
        uint256 tokenId = 1;
        uint256 requestId = 2;
        Reveal.startReveal(tokenId, requestId);
        Reveal.endReveal(requestId);

        // Act & Assert
        vm.expectRevert(abi.encodeWithSelector(RevealError.RevealProcessNotInProgress.selector, 0));
        Reveal.endReveal(requestId);
    }
}
