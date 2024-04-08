// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ReentrancyLock
 * @dev The ReentrancyLock contract provides functions to lock and unlock the reentrancy.
 */
library ReentrancyLock {
    bytes32 private constant _REENTRANCY_LOCK_STORAGE = keccak256("src.utils.ReentrancyLock.storage");

    /*
     * @dev It defends against reentrancy attacks.
     */
    function lock() internal {
        bytes32 key = _REENTRANCY_LOCK_STORAGE;
        assembly {
            let lockFlag := tload(key)
            if eq(lockFlag, true) {
                mstore(0x0, 0xb52e0973) // ReentrancyLockError()
                revert(0x0, 0x4)
            }
            tstore(key, true)
        }
    }

    /*
     * @dev It unlocks the reentrancy.
     */
    function unlock() internal {
        bytes32 key = _REENTRANCY_LOCK_STORAGE;
        assembly {
            tstore(key, false)
        }
    }

    /**
     * @dev Check if the reentrancy is locked.
     * @return lockFlag True if the reentrancy is locked.
     */
    function isLocked() internal view returns (bool lockFlag) {
        bytes32 key = _REENTRANCY_LOCK_STORAGE;
        assembly {
            lockFlag := tload(key)
        }
    }
}

/**
 * @title UsingReentrancyLock
 * @dev The UsingReentrancyLock contract provides modifier to prevent reentrancy.
 */
contract UsingReentrancyLock {
    modifier nonReentrant() {
        ReentrancyLock.lock();
        _;
        ReentrancyLock.unlock();
    }
}
