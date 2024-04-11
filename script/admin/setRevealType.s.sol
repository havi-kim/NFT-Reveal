//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "../shared/ScriptHelper.s.sol";

/**
 * @title Setter of reveal type
 * @dev Use this script `REVEAL_TYPE=0 yarn setRevealType`
 */
contract setRevealType is ScriptHelper {
    function run() external printEvents {
        // 0. Get environment variables
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        // 1. Read JSON file
        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        // 2. Get contract list
        NetworkConfig memory networkConfig = getNetworkConfig();

        // 3. Set reveal type in config
        networkConfig.revealType =
            uint256(vm.envOr("REVEAL_TYPE", uint256(1))) == 0 ? RevealType.InCollection : RevealType.SeparateCollection;

        // 4. Start broadcast
        vm.startBroadcast(networkConfig.pk);

        // 5. Set reveal type
        console.log("Set reveal type");
        networkConfig.nft.setRevealType(networkConfig.revealType);

        // 6. Stop broadcast
        vm.stopBroadcast();

        // 7. Store network configuration
        storeNetworkConfig(networkConfig);
    }
}
