//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "../shared/ScriptHelper.s.sol";

/**
 * @title Setter of mint price
 * @dev Use this script `MINT_PRICE=10000..0 yarn setMintPrice`
 */
contract setMintPrice is ScriptHelper {
    function run() external printEvents {
        // 0. Get environment variables
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        // 1. Read JSON file
        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        // 2. Get contract list
        NetworkConfig memory networkConfig = getNetworkConfig();

        // 3. Set mint price in config
        networkConfig.mintPrice = uint96(vm.envOr("MINT_PRICE", uint256(1e18)));

        // 4. Start broadcast
        vm.startBroadcast(networkConfig.pk);

        // 5. Set mint price
        console.log("Set mint price");
        networkConfig.nft.setMintPrice(networkConfig.mintPrice);

        // 6. Stop broadcast
        vm.stopBroadcast();

        // 7. Store network configuration
        storeNetworkConfig(networkConfig);
    }
}
