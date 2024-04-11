//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "../shared/ScriptHelper.s.sol";

/**
 * @title Setter of reveal start block
 * @dev Use this script `REVEAL_START_BLOCK=100 yarn setRevealStartBlock`
 */
contract setRevealStartBlock is ScriptHelper {
    function run() external printEvents {
        // 0. Get environment variables
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        // 1. Read JSON file
        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        // 2. Get contract list
        NetworkConfig memory networkConfig = getNetworkConfig();

        // 3. Set reveal start block in config
        networkConfig.revealStartBlock = uint48(vm.envOr("REVEAL_START_BLOCK", block.number + 10));

        // 4. Start broadcast
        vm.startBroadcast(networkConfig.pk);

        // 5. Set reveal start block
        console.log("Set reveal start block");
        networkConfig.nft.setRevealStartBlock(networkConfig.revealStartBlock);

        // 6. Stop broadcast
        vm.stopBroadcast();

        // 7. Store network configuration
        storeNetworkConfig(networkConfig);
    }
}
