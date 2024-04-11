// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RevealType} from "../types/GlobalEnum.sol";
import {ConfigError} from "src/errors/Error.sol";

library Config {
    bytes32 private constant _CONFIG_STORAGE = keccak256("src.objects.Config.storage.v1");

    // NFT mint & reveal configuration. Using 1 slot.
    struct ConfigStorage {
        // Mint config
        uint96 mintPrice;
        uint48 mintStartBlock;
        // Reveal config
        RevealType revealType;
        uint48 revealStartBlock;
    }

    /**
     * @dev Initialize the Config.
     * @param mintPrice_ The mint price.
     * @param mintStartBlock_ The mint start block.
     * @param revealType_ The reveal type.
     * @param revealStartBlock_ The reveal start block.
     */
    function init(uint96 mintPrice_, uint48 mintStartBlock_, RevealType revealType_, uint48 revealStartBlock_)
        internal
    {
        ConfigStorage storage data = read();

        // 0. Check the validity of the parameters
        {
            if (mintPrice_ == 0) {
                revert ConfigError.MintPriceShouldNotBeZero();
            }
            if (mintStartBlock_ <= block.number) {
                revert ConfigError.MintStartBlockShouldBeGreaterThanCurrentBlock(mintStartBlock_, block.number);
            }
            if (revealStartBlock_ <= mintStartBlock_) {
                revert ConfigError.MintStartShouldEarlierThanRevealStart(mintStartBlock_, revealStartBlock_);
            }
        }

        // 1. Check double initialization
        {
            if (data.mintPrice != 0) {
                revert ConfigError.ConfigAlreadyInitialized();
            }
        }

        // 2. Initialize the storage
        {
            data.mintPrice = mintPrice_;
            data.mintStartBlock = mintStartBlock_;
            data.revealType = revealType_;
            data.revealStartBlock = revealStartBlock_;
        }
    }

    /**
     * @dev Set the mint price.
     * @param price_ The mint price.
     */
    function setMintPrice(uint96 price_) internal {
        ConfigStorage storage data = read();

        // 0. Check if mint has started
        {
            if (isMintStarted()) {
                revert ConfigError.MintAlreadyStarted();
            }
        }

        // 1. Set the mint price in storage
        {
            data.mintPrice = price_;
        }
    }

    /**
     * @dev Set the start block of mint.
     * @param startBlock_ The start block of mint.
     */
    function setMintStartBlock(uint48 startBlock_) internal {
        ConfigStorage storage data = read();

        // 0. Check validity of the status
        {
            if (isMintStarted()) {
                revert ConfigError.MintAlreadyStarted();
            }
            if (startBlock_ <= block.number) {
                revert ConfigError.MintStartBlockShouldBeGreaterThanCurrentBlock(startBlock_, block.number);
            }
            if (startBlock_ >= data.revealStartBlock) {
                revert ConfigError.MintStartShouldEarlierThanRevealStart(startBlock_, data.revealStartBlock);
            }
        }

        // 1. Set the start block of mint in storage
        {
            data.mintStartBlock = startBlock_;
        }
    }

    /**
     * @dev Set the reveal type.
     * @param revealType_ The reveal type.
     */
    function setRevealType(RevealType revealType_) internal {
        ConfigStorage storage data = read();

        // 0. Check if reveal has started
        {
            if (isRevealStarted()) {
                revert ConfigError.RevealAlreadyStarted();
            }
        }

        // 1. Set the reveal type in storage
        {
            data.revealType = revealType_;
        }
    }

    /**
     * @dev Set the start block of revealing.
     * @param startBlock_ The start block of revealing.
     */
    function setRevealStartBlock(uint48 startBlock_) internal {
        ConfigStorage storage data = read();

        // 0. Check if reveal has started
        {
            if (isRevealStarted()) {
                revert ConfigError.RevealAlreadyStarted();
            }
        }

        // 1. Set the start block of revealing in storage
        {
            data.revealStartBlock = startBlock_;
        }
    }

    /**
     * @dev Return whether mint has started.
     * @return True if mint has started.
     */
    function isMintStarted() internal view returns (bool) {
        return block.number >= read().mintStartBlock;
    }

    /**
     * @dev Return whether reveal has started.
     * @return True if reveal has started.
     */
    function isRevealStarted() internal view returns (bool) {
        return block.number >= read().revealStartBlock;
    }

    /**
     * @dev Get the mint price.
     * @return The mint price.
     */
    function mintPrice() internal view returns (uint96) {
        return read().mintPrice;
    }

    /**
     * @dev Get the reveal type.
     * @return The reveal type.
     */
    function revealType() internal view returns (RevealType) {
        return read().revealType;
    }

    /**
     * @dev Copy the Config to memory. Only for view functions.
     */
    function copy() internal view returns (ConfigStorage memory) {
        return read();
    }

    /**
     * @dev Read the storage slot of the Config. If change visibility of this function to internal, encapsulation will break.
     * @return data The storage slot.
     */
    function read() private pure returns (ConfigStorage storage data) {
        bytes32 key = _CONFIG_STORAGE;
        assembly {
            data.slot := key
        }
    }
}
