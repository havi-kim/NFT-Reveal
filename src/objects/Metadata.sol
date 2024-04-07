// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library Metadata {
    bytes32 private constant _METADATA_STORAGE = keccak256("src.objects.Metadata.storage.v1");

    // This is the metadata of the NFT. Using 1 slot.
    struct MetadataStorage {
        bool initialized;
        uint16 strength;
        uint16 intelligence;
        uint16 wisdom;
        uint16 charisma;
        uint16 dexterity;
        uint144 unused;
    }

    /**
     * @dev Initialize the Metadata.
     * @param tokenId_ The token ID.
     * @param metadata_ The metadata of the NFT.
     */
    function setMetadata(uint256 tokenId_, uint256 metadata_) internal {
        MetadataStorage storage data = read(tokenId_);
        if (data.initialized) {
            revert("setMetadata: Already set");
        }
        assembly {
            sstore(data.slot, metadata_)
        }
        data.initialized = true;
    }

    /**
     * @dev Get the metadata of the NFT.
     * @param tokenId_ The token ID.
     * @return The metadata of the NFT.
     */
    function getMetadata(uint256 tokenId_) internal view returns (string memory) {
        MetadataStorage storage data = read(tokenId_);
        if (!data.initialized) {
            return '{"name": "Unrevealed NFT", "description": "This is a unrevealed NFT."}';
        }
        return string(
            abi.encodePacked(
                '{"name": "The revealed NFT-',
                Strings.toString(tokenId_),
                '", "stats": {',
                '"strength": ',
                Strings.toString(data.strength),
                ', "intelligence": ',
                Strings.toString(data.intelligence),
                ', "wisdom": ',
                Strings.toString(data.wisdom),
                ', "charisma": ',
                Strings.toString(data.charisma),
                ', "dexterity": ',
                Strings.toString(data.dexterity),
                "}}"
            )
        );
    }

    /**
     * @dev Read the storage slot of the Metadata. If change visibility of this function to internal, encapsulation will break.
     * @param tokenId_ The token ID.
     * @return data The storage slot of the Metadata.
     */
    function read(uint256 tokenId_) private pure returns (MetadataStorage storage data) {
        bytes32 key = keccak256(abi.encodePacked(_METADATA_STORAGE, tokenId_));
        assembly {
            data.slot := key
        }
    }
}
