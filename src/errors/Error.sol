// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {RevealType} from "src/types/GlobalEnum.sol";

// Config Error
library ConfigError {
    /**
     * @dev Mint price should not be zero.
     */
    error MintPriceShouldNotBeZero();

    /**
     * @dev Insufficient payment.
     * @param mintPrice_ The mint price.
     * @param msgValue_ The message value.
     */
    error InsufficientPayment(uint mintPrice_, uint msgValue_);

    /**
     * @dev When setting the mint start block, it should be greater than the current block.
     * @param mintStartBlock_ The mint start block.
     * @param currentBlock_ The current block.
     */
    error MintStartBlockShouldBeGreaterThanCurrentBlock(uint mintStartBlock_, uint currentBlock_);

    /**
     * @dev When setting the reveal start block, it should be greater than the mint start block.
     * @param mintStartBlock_ The mint start block.
     * @param revealStartBlock_ The reveal start block.
     */
    error MintStartShouldEarlierThanRevealStart(uint mintStartBlock_, uint revealStartBlock_);

    /**
     * @dev The configuration has already been initialized.
     */
    error ConfigAlreadyInitialized();

    /**
     * @dev Mint has already started.
     */
    error MintAlreadyStarted();

    /**
     * @dev Mint has not started.
     */
    error MintingHasNotStarted();

    /**
     * @dev Reveal has already started.
     */
    error RevealAlreadyStarted();

    /**
     * @dev Reveal has not started.
     */
    error RevealHasNotStarted();

    /**
     * @dev Only separate collection type.
     */
    error OnlySeparateCollectionType();
}

// Metadata Error
library MetadataError {
    /**
     * @dev The metadata has already been initialized.
     */
    error MetadataAlreadyInitialized();
}

// Reveal Error
library RevealError {
    /**
     * @dev The token ID has already been revealed.
     * @param tokenId_ The token ID which has already been revealed.
     */
    error RevealProcessAlreadyStarted(uint tokenId_);

    /**
     * @dev The token ID has not in the reveal process.
     * @param tokenId_ The token ID which has not in the reveal process.
     */
    error RevealProcessNotInProgress(uint tokenId_);
}

// Collection Error
library CollectionError {
    /**
     * @dev The collection has already been created.
     * @param alreadyCreatedNFT_ The already created NFT address.
     */
    error CollectionAlreadyCreated(address alreadyCreatedNFT_);

    /**
     * @dev The collection has not been created.
     */
    error CollectionNotCreated();

    /**
     * @dev Invalid collection type.
     * @param revealType_ The reveal type.
     */
    error InvalidCollectionType(RevealType revealType_);
}

// Revealed NFT Error
library RevealedNFTError {
    /**
     * @dev Only parent NFT.
     * @param parentNFT_ The parent NFT address.
     * @param caller_ The caller address.
     */
    error OnlyParentNFT(address parentNFT_, address caller_);
}