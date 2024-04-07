//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {IdGenerator, IdSeed} from "src/utils/IdGenerator.sol";

// This is a test code wrapper for forge coverage issue.
contract WIdGeneratorUnitTest {
    IdGeneratorUnitTest private idGeneratorUnitTest;

    function setUp() public {
        idGeneratorUnitTest = new IdGeneratorUnitTest();
    }

    // @success_test
    function test_generateSharedIncrementalId() external {
        idGeneratorUnitTest.$test_generateSharedIncrementalId();
    }

    // @success_test
    function test_generateUniqueIncrementalId() external {
        idGeneratorUnitTest.$test_generateUniqueIncrementalId_0();
        idGeneratorUnitTest.$test_generateUniqueIncrementalId_1();
    }
}

contract IdGeneratorUnitTest is Test {
    // @success_test
    function $test_generateSharedIncrementalId() external {
        // Act
        uint256 id = IdGenerator.generateSharedIncrementalId();
        uint256 id2 = IdGenerator.generateSharedIncrementalId();

        // Assert
        assertEq(id2, IdGenerator.getLastSharedId(), "Last shared id should be equal to the last generated id");
        assertEq(id + 1, id2, "Generated id should be incremental");
    }

    // @success_test
    function $test_generateUniqueIncrementalId_0() external {
        // Arrange
        IdSeed key = IdSeed.wrap(keccak256(abi.encode("TestKey")));

        // Act
        uint256 id = IdGenerator.generateUniqueIncrementalId(key);

        // Assert
        assertEq(id, IdGenerator.getLastUniqueId(key), "Last unique id should be equal to the last generated id");
    }

    // @success_test
    function $test_generateUniqueIncrementalId_1() external {
        // Arrange
        IdSeed key = IdSeed.wrap(keccak256(abi.encode("TestKey2")));
        IdSeed key2 = IdSeed.wrap(keccak256(abi.encode("TestKey3")));

        // Act
        uint256 id = IdGenerator.generateUniqueIncrementalId(key);
        uint256 id2 = IdGenerator.generateUniqueIncrementalId(key2);

        // Assert
        assertEq(id, IdGenerator.getLastUniqueId(key), "Last unique id should be equal to the last generated id");
        assertEq(id2, IdGenerator.getLastUniqueId(key2), "Last unique id should be equal to the last generated id");
        assertEq(id, id2, "Generated id should be not shared between different keys");
    }
}
