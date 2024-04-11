//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {ERC1967Proxy} from "@openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "../shared/ScriptHelper.s.sol";

/**
 * @title Mint NFT
 * @dev Use this script `yarn mintNFT`
 */
contract mintNFT is ScriptHelper {
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

        // 4. Mint NFT
        console.log("Mint NFT");
        uint256 tokenId = networkConfig.nft.mint{value: networkConfig.mintPrice}();
        console.log("Minted NFT with tokenId: ", tokenId);

        // 6. Stop broadcast
        vm.stopBroadcast();
    }
}
