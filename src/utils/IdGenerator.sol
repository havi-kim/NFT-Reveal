// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IdSeed is used to generate unique identifiers.
type IdSeed is bytes32;

using IdGenerator for IdSeed global;

/**
 * @title IdGenerator
 * @dev The IdGenerator library provides functions to generate unique identifiers.
 */
library IdGenerator {
    bytes32 private constant _ID_GENERATOR_STORAGE = keccak256("src.objects.IdGenerator.storage");

    struct IdGeneratorStorage {
        uint256 lastId;
    }

    /**
     * @dev Generate a shared unique identifier. It is shared across contract.
     * @return The shared identifier.
     */
    function generateSharedIncrementalId() internal returns (uint256) {
        IdGeneratorStorage storage idGenerator = read();
        idGenerator.lastId += 1;
        return idGenerator.lastId;
    }

    /**
     * @dev Generate a unique identifier with a key. It is only shared within same seed.
     * @param _seed The key to generate the unique identifier.
     * @return data The unique identifier.
     */
    function generateUniqueIncrementalId(IdSeed _seed) internal returns (uint256) {
        IdGeneratorStorage storage idGenerator = readByKey(_seed);
        idGenerator.lastId += 1;
        return idGenerator.lastId;
    }

    /**
     * @dev Get the last shared identifier.
     * @return The last shared identifier.
     */
    function getLastSharedId() internal view returns (uint256) {
        return read().lastId;
    }

    /**
     * @dev Get the last unique identifier with a key.
     * @param _seed The key to get the last unique identifier.
     * @return The last unique identifier.
     */
    function getLastUniqueId(IdSeed _seed) internal view returns (uint256) {
        return readByKey(_seed).lastId;
    }


    /**
     * @dev Read the storage slot of the IdGenerator. If change visibility of this function to internal, encapsulation will break.
     * @return data The storage slot.
     */
    function read() private pure returns (IdGeneratorStorage storage data) {
        bytes32 key = _ID_GENERATOR_STORAGE;
        assembly {
            data.slot := key
        }
    }

    /**
     * @dev Read the storage slot of the IdGenerator with a key. If change visibility of this function to internal, encapsulation will break.
     * @param _seed The key to read the storage slot.
     * @return data The storage slot.
     */
    function readByKey(IdSeed _seed) private pure returns (IdGeneratorStorage storage data) {
        bytes32 key = keccak256(abi.encodePacked(_ID_GENERATOR_STORAGE, _seed));
        assembly {
            data.slot := key
        }
    }
}
