// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Reveal {
    bytes32 private constant _STATUS_STORAGE = keccak256("src.objects.Reveal.StatusStorage.v1");
    bytes32 private constant _REQUEST_STORAGE = keccak256("src.objects.Reveal.RequestStorage.v1");

    enum RevealStatus {
        NOT_REVEALED,
        IN_PROGRESS,
        REVEALED
    }

    struct RevealStatusStorage {
        RevealStatus status;
    }

    struct RevealRequestStorage {
        address to;
        uint96 tokenId; // Incremental ID cannot over 2^96
    }

    /**
     * @dev Start the reveal process. If reveal process is already started, it will revert.
     * @param tokenId_ The token ID.
     * @param requestId_ The request ID.
     */
    function startReveal(uint256 tokenId_, uint256 requestId_) internal {
        // 0. Read storage slots
        RevealStatusStorage storage statusData = readStatus(tokenId_);
        RevealRequestStorage storage requestData = readRequest(requestId_);

        // 1. Check the status
        if (statusData.status != RevealStatus.NOT_REVEALED) {
            revert("setStatusInProgress: Already started");
        }

        // 2. Set the status
        statusData.status = RevealStatus.IN_PROGRESS;
        requestData.to = msg.sender;
        requestData.tokenId = uint96(tokenId_); // Incremental ID cannot over 2^96
    }

    /**
     * @dev End the reveal process. If the reveal process is not in progress, it will revert.
     * @param requestId_ The request ID.
     * @return tokenId The token ID.
     * @return to The address of the receiver.
     */
    function endReveal(uint256 requestId_) internal returns (uint256 tokenId, address to) {
        // 0. Read the reveal request & set the return values
        RevealRequestStorage storage requestData = readRequest(requestId_);
        (tokenId, to) = (uint256(requestData.tokenId), requestData.to);

        // 1. Read the reveal status
        RevealStatusStorage storage statusData = readStatus(tokenId);

        // 2. Check the status
        if (statusData.status != RevealStatus.IN_PROGRESS) {
            revert("setStatusRevealed: Not in progress");
        }

        // 3. Set the status
        statusData.status = RevealStatus.REVEALED;
        requestData.to = address(0);
        requestData.tokenId = 0;
    }

    /**
     * @dev Get the reveal status of the token.
     * @param tokenId_ The token ID.
     * @return The reveal status.
     */
    function getRevealStatus(uint256 tokenId_) internal view returns (RevealStatus) {
        return readStatus(tokenId_).status;
    }

    /**
     * @dev Get the reveal request.
     * @param requestId_ The request ID.
     * @return to The address of the receiver.
     * @return tokenId The token ID.
     */
    function getRevealRequest(uint256 requestId_) internal view returns (address to, uint256 tokenId) {
        RevealRequestStorage storage requestData = readRequest(requestId_);
        return (requestData.to, uint(requestData.tokenId));
    }

    /**
     * @dev Read the storage slot of the reveal status. If change visibility of this function to internal, encapsulation will break.
     * @return data The storage slot of the reveal status.
     */
    function readStatus(uint256 tokenId_) private pure returns (RevealStatusStorage storage data) {
        bytes32 key = keccak256(abi.encodePacked(_STATUS_STORAGE, tokenId_));
        assembly {
            data.slot := key
        }
    }

    /**
     * @dev Read the storage slot of the reveal request. If change visibility of this function to internal, encapsulation will break.
     * @return data The storage slot of the reveal request.
     */
    function readRequest(uint256 requestId_) private pure returns (RevealRequestStorage storage data) {
        bytes32 key = keccak256(abi.encodePacked(_REQUEST_STORAGE, requestId_));
        assembly {
            data.slot := key
        }
    }
}
