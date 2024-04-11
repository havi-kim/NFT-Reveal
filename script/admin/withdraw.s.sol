//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "../shared/ScriptHelper.s.sol";

/**
 * @title Withdraw eth from nft contract
 * @dev Use this script `yarn withdraw`
 */
contract withdraw is ScriptHelper {
    function run() external printEvents {
        // 0. Get environment variables
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));
        uint256 withdrawAmount = vm.envOr("AMOUNT", uint(1e18));

        // 1. Read JSON file
        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        // 2. Get contract list
        NetworkConfig memory networkConfig = getNetworkConfig();

        // 3. Start broadcast
        vm.startBroadcast(networkConfig.pk);

        // 4. Withdraw eth from nft contract
        console.log("Withdraw");
        networkConfig.nft.withdraw(withdrawAmount);

        // 5. Stop broadcast
        vm.stopBroadcast();
    }
}
