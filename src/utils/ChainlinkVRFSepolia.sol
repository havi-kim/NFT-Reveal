// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/vrf/VRFCoordinatorV2Interface.sol";

library ChainlinkVRFSepolia {
    /*
     * @dev Chainlink VRF configuration (Sepolia).
     *      It is recommended that configurations that are unlikely to change are declared constant and modified by contract upgrade.
     *      It can save sload gas cost.
     */
    VRFCoordinatorV2Interface private constant _VRF_COORDINATOR =
        VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
    address private constant _LINK_TOKEN = address(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    bytes32 private constant _VRF_KEY_HASH = bytes32(0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c);
    uint16 private constant _VRF_REQUEST_CONFIRMATION = 3;
    uint32 private constant _CALLBACK_GAS_LIMIT = 500000;
    uint64 private constant _SUBSCRIPTION_ID = uint64(0);

    /**
     * @dev Request random words from Chainlink VRF.
     * @param numWord_ The number of words to request.
     * @return requestId The request ID.
     */
    function request(uint32 numWord_) internal returns (uint256 requestId) {
        requestId = _VRF_COORDINATOR.requestRandomWords(
            _VRF_KEY_HASH, _SUBSCRIPTION_ID, _VRF_REQUEST_CONFIRMATION, _CALLBACK_GAS_LIMIT, numWord_
        );
    }
}
