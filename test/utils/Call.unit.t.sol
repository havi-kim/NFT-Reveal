//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {Call} from "src/utils/Call.sol";

// This is a test code wrapper for forge coverage issue.
contract WCallUnitTest {
    CallUnitTest private testTarget;

    function setUp() public {
        testTarget = new CallUnitTest();
    }

    // @succes_test
    function test_pay() external {
        testTarget.$test_pay{value: 10e18}();
    }
}

contract CallUnitTest is Test {
    // @succes_test
    function $test_pay() external payable {
        // Arrange
        address target = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        uint balanceOfThis = address(this).balance;
        uint balanceOfTarget = address(target).balance;
        uint value = 1e18;

        // Act
        Call.pay(target, value);

        // Assert
        assertEq(address(this).balance, balanceOfThis - value, "The balance of this address is not decreased");
        assertEq(address(target).balance, balanceOfTarget + value, "The balance of target address is not increased");
    }
}
