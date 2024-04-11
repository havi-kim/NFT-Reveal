//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Test.sol";

import {Config} from "src/objects/Config.sol";
import {RevealType} from "src/types/GlobalEnum.sol";
import {ConfigError} from "src/errors/Error.sol";

// This is a test code wrapper for forge coverage issue(forge coverage miss library test codes).
contract WConfigUnitTest {
    ConfigUnitTest private testTarget;

    function setUp() public {
        testTarget = new ConfigUnitTest();
    }

    // @succes_test
    function test_init() external {
        testTarget.$test_init();
    }

    // @fail_test
    function test_init_fail() external {
        testTarget.$test_init_fail_0();
        testTarget.$test_init_fail_1();
        testTarget.$test_init_fail_2();
        testTarget.$test_init_fail_3();
    }
    // @succes_test

    function test_setMintingPrice() external {
        testTarget.$test_setMintingPrice();
    }

    // @fail_test
    function test_setMintingPrice_fail() external {
        testTarget.$test_setMintingPrice_fail_0();
    }

    // @succes_test
    function test_setMintStartBlock() external {
        testTarget.$test_setMintStartBlock();
    }

    // @fail_test
    function test_setMintStartBlock_fail() external {
        testTarget.$test_setMintStartBlock_fail_0();
        testTarget.$test_setMintStartBlock_fail_1();
        testTarget.$test_setMintStartBlock_fail_2();
    }

    // @succes_test
    function test_setRevealType() external {
        testTarget.$test_setRevealType();
    }

    // @fail_test
    function test_setRevealType_fail() external {
        testTarget.$test_setRevealType_fail_0();
    }

    // @succes_test
    function test_setRevealStartBlock() external {
        testTarget.$test_setRevealStartBlock();
    }

    // @fail_test
    function test_setRevealStartBlock_fail() external {
        testTarget.$test_setRevealStartBlock_fail_0();
    }
}

contract ConfigUnitTest is Test {
    // @succes_test
    function $test_init() external {
        // Arrange
        uint96 mintPrice = 100;
        uint48 mintStartBlock = uint48(block.number + 10);
        RevealType revealType = RevealType.InCollection;
        uint48 revealStartBlock = mintStartBlock + 10;

        // Act
        Config.init(mintPrice, mintStartBlock, revealType, revealStartBlock);

        // Assert
        assertEq(Config.mintPrice(), mintPrice, "Mint price is not set correctly");
        assertFalse(Config.isMintStarted(), "Mint start block is not set correctly");
        assertTrue(Config.revealType() == revealType, "Reveal type is not set correctly");
        assertFalse(Config.isRevealStarted(), "Reveal start block is not set correctly");
    }

    // @fail_test Case: mintPrice == 0
    function $test_init_fail_0() external {
        // Arrange
        uint96 mintPrice = 0;

        // Act
        vm.expectRevert(ConfigError.MintPriceShouldNotBeZero.selector);
        Config.init(mintPrice, 0, RevealType.InCollection, 0);
    }

    // @fail_test Case: mintStartBlock <= block.number
    function $test_init_fail_1() external {
        // Arrange
        uint96 mintPrice = 100;
        uint48 mintStartBlock = uint48(block.number - 1);

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                ConfigError.MintStartBlockShouldBeGreaterThanCurrentBlock.selector, mintStartBlock, block.number
            )
        );
        Config.init(mintPrice, mintStartBlock, RevealType.InCollection, 0);
    }

    // @fail_test Case: revealStartBlock <= mintStartBlock
    function $test_init_fail_2() external {
        // Arrange
        uint96 mintPrice = 100;
        uint48 mintStartBlock = uint48(block.number + 10);
        uint48 revealStartBlock = mintStartBlock - 1;

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                ConfigError.MintStartShouldEarlierThanRevealStart.selector, mintStartBlock, revealStartBlock
            )
        );
        Config.init(mintPrice, mintStartBlock, RevealType.InCollection, revealStartBlock);
    }

    // @fail_test Case: double initialization
    function $test_init_fail_3() external {
        // Arrange
        uint96 mintPrice = 100;
        uint48 mintStartBlock = uint48(block.number + 10);
        RevealType revealType = RevealType.InCollection;
        uint48 revealStartBlock = mintStartBlock + 10;
        Config.init(mintPrice, mintStartBlock, revealType, revealStartBlock);

        // Act
        vm.expectRevert(ConfigError.ConfigAlreadyInitialized.selector);
        Config.init(mintPrice, mintStartBlock, revealType, revealStartBlock);
    }

    // @succes_test
    function $test_setMintingPrice() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 2));

        // Act
        Config.setMintPrice(200);

        // Assert
        assertEq(Config.mintPrice(), 200, "Mint price is not set correctly");
    }

    // @fail_test Case: minting has already started
    function $test_setMintingPrice_fail_0() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 20));
        vm.roll(block.number + 10);

        // Act
        vm.expectRevert(ConfigError.MintAlreadyStarted.selector);
        Config.setMintPrice(200);
    }

    // @succes_test
    function $test_setMintStartBlock() external {
        // Arrange
        Config.init(1, uint48(block.number + 100), RevealType.InCollection, uint48(block.number + 200));

        // Act
        Config.setMintStartBlock(uint48(block.number + 1));
        vm.roll(block.number + 1);

        // Assert
        assertTrue(Config.isMintStarted(), "Mint start block is not set correctly");
    }

    // @fail_test Case: minting has already started
    function $test_setMintStartBlock_fail_0() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 20));
        vm.roll(block.number + 10);

        // Act
        vm.expectRevert(ConfigError.MintAlreadyStarted.selector);
        Config.setMintStartBlock(uint48(block.number + 1));
    }

    // @fail_test Case: startBlock <= block.number
    function $test_setMintStartBlock_fail_1() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 20));

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                ConfigError.MintStartBlockShouldBeGreaterThanCurrentBlock.selector, block.number, block.number
            )
        );
        Config.setMintStartBlock(uint48(block.number));
    }

    // @fail_test Case: startBlock >= revealStartBlock
    function $test_setMintStartBlock_fail_2() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 20));

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                ConfigError.MintStartShouldEarlierThanRevealStart.selector, block.number + 20, block.number + 20
            )
        );
        Config.setMintStartBlock(uint48(block.number + 20));
    }

    // @succes_test
    function $test_setRevealType() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 2));

        // Act
        Config.setRevealType(RevealType.SeparateCollection);

        // Assert
        assertTrue(Config.revealType() == RevealType.SeparateCollection, "Reveal type is not set correctly");
    }

    // @fail_test Case: reveal has already started
    function $test_setRevealType_fail_0() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 2));
        vm.roll(block.number + 2);

        // Act
        vm.expectRevert(ConfigError.RevealAlreadyStarted.selector);
        Config.setRevealType(RevealType.SeparateCollection);
    }

    // @succes_test
    function $test_setRevealStartBlock() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 2));

        // Act
        Config.setRevealStartBlock(uint48(block.number + 1));
        vm.roll(block.number + 1);

        // Assert
        assertTrue(Config.isRevealStarted(), "Reveal start block is not set correctly");
    }

    // @fail_test Case: reveal has already started
    function $test_setRevealStartBlock_fail_0() external {
        // Arrange
        Config.init(1, uint48(block.number + 1), RevealType.InCollection, uint48(block.number + 2));
        vm.roll(block.number + 2);

        // Act
        vm.expectRevert(ConfigError.RevealAlreadyStarted.selector);
        Config.setRevealStartBlock(uint48(block.number + 1));
    }
}
