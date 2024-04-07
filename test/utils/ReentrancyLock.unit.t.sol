//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {ReentrancyLock} from "../../src/utils/ReentrancyLock.sol";

contract ReentrancyLockUnitTest is Test {
    TestContract private testContract;

    function setUp() public {
        testContract = new TestContract();
    }

    // @success_test
    function test_lock() external {
        // Act
        testContract.lockWithoutCallback();

        // Assert
        assertTrue(testContract.isLocked());
    }

    // @fail_test Case: ReentrancyLock.lock() is called twice
    function test_lock_fail() external {
        // Act
        vm.expectRevert();
        testContract.lockWithCallback();
    }

    function callback() external {
        testContract.lockWithoutCallback();
    }
}

contract TestContract {
    function lockWithCallback() external {
        ReentrancyLock.lock();
        ReentrancyLockUnitTest(msg.sender).callback();
    }

    function lockWithoutCallback() external {
        ReentrancyLock.lock();
    }

    function isLocked() external view returns (bool) {
        return ReentrancyLock.isLocked();
    }
}
