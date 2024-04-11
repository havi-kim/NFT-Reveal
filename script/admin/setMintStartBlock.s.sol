//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {ERC1967Proxy} from "@openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "../shared/ScriptHelper.s.sol";

/**
 * @title Setter of mint start block
 * @dev Use this script `MINT_START_BLOCK=100 yarn setMintStartBlock`
 */
contract setMintStartBlock is ScriptHelper {
    function run() external printEvents {
        // 0. Get environment variables
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        // 1. Read JSON file
        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        // 2. Get contract list
        NetworkConfig memory networkConfig = getNetworkConfig();

        // 3. Set mint start block in config
        networkConfig.mintStartBlock = uint48(vm.envOr("MINT_START_BLOCK", block.number + 10));

        // 4. Start broadcast
        vm.startBroadcast(networkConfig.pk);

        // 5. Set mint start block
        console.log("Set mint start block");
        networkConfig.nft.setMintStartBlock(networkConfig.mintStartBlock);

        // 6. Stop broadcast
        vm.stopBroadcast();

        // 7. Store network configuration
        storeNetworkConfig(networkConfig);
    }
}
