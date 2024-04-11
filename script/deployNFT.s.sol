//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {ERC1967Proxy} from "@openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "./shared/ScriptHelper.s.sol";

/**
 * @title Deploy NFT contract
 */
contract deployNFT is ScriptHelper {
    function run() external printEvents {
        // 0. Get environment variables
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        // 1. Read JSON file
        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        // 2. Get contract list
        NetworkConfig memory networkConfig = getNetworkConfig();

        // 3. Start broadcast
        vm.startBroadcast(networkConfig.pk);

        // 4. Deploy NFT contract
        console.log("Deploy NFT contract");
        address impl = address(new NFT());

        // 5. Initialize NFT contract
        console.log("Initialize NFT contract");
        bytes memory initData = abi.encodeWithSelector(
            NFT.initialize.selector,
            networkConfig.nftName,
            networkConfig.nftSymbol,
            networkConfig.coordinator,
            networkConfig.mintPrice,
            networkConfig.mintStartBlock,
            networkConfig.revealType,
            networkConfig.revealStartBlock
        );
        networkConfig.nft = NFT(address(new ERC1967Proxy(impl, initData)));

        // 6. Stop broadcast
        vm.stopBroadcast();

        // 7. Store network configuration
        storeNetworkConfig(networkConfig);
    }
}
