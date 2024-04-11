//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "forge-std/Script.sol";

import {RevealType} from "src/types/GlobalEnum.sol";
import {RevealedNFT} from "src/RevealedNFT.sol";
import {PurchasableNFT} from "src/PurchasableNFT.sol";

contract ScriptHelper is Script {
    struct NetworkConfig {
        address account;
        uint256 pk;
        PurchasableNFT nft;
        RevealedNFT revealedNft;
        address coordinator;
        string nftName;
        string nftSymbol;
        uint96 mintPrice;
        uint48 mintStartBlock;
        RevealType revealType;
        uint48 revealStartBlock;
    }

    /**
     * @dev Get the network configuration.
     * @return config The network configuration.
     */
    function getNetworkConfig() internal view returns (NetworkConfig memory config) {
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        config.account = vm.parseJsonAddress(json, ".00_ACCOUNT");
        config.pk = vm.parseJsonUint(json, ".01_PK");
        config.nft = PurchasableNFT(vm.parseJsonAddress(json, ".02_NFT"));
        config.revealedNft = RevealedNFT(vm.parseJsonAddress(json, ".03_REVEALED_NFT"));
        config.coordinator = vm.parseJsonAddress(json, ".04_VRF_COORDINATOR");
        config.nftName = vm.parseJsonString(json, ".05_NFT_NAME");
        config.nftSymbol = vm.parseJsonString(json, ".06_NFT_SYMBOL");
        config.mintPrice = uint96(vm.parseJsonUint(json, ".07_MINT_PRICE"));
        config.mintStartBlock = uint48(vm.parseJsonUint(json, ".08_MINT_START_BLOCK"));
        config.revealType =
            vm.parseJsonUint(json, ".09_REVEAL_TYPE") == 0 ? RevealType.InCollection : RevealType.SeparateCollection;
        config.revealStartBlock = uint48(vm.parseJsonUint(json, ".10_REVEAL_START_BLOCK"));
    }

    /**
     * @dev Store the network configuration.
     * @param config The network configuration.
     */
    function storeNetworkConfig(NetworkConfig memory config) internal {
        string memory deployVersion = vm.envOr("VERSION", string("v0.0.1"));
        string memory network = vm.envOr("NETWORK", string("LOCAL"));

        string memory path = string.concat(vm.projectRoot(), "/networks/", network, "_", deployVersion, ".json");
        string memory json = vm.readFile(path);

        vm.serializeAddress("Network config JSON", "00_ACCOUNT", config.account);
        vm.serializeUint("Network config JSON", "01_PK", config.pk);
        vm.serializeAddress("Network config JSON", "02_NFT", address(config.nft));
        vm.serializeAddress("Network config JSON", "03_REVEALED_NFT", address(config.revealedNft));
        vm.serializeAddress("Network config JSON", "04_VRF_COORDINATOR", config.coordinator);
        vm.serializeString("Network config JSON", "05_NFT_NAME", config.nftName);
        vm.serializeString("Network config JSON", "06_NFT_SYMBOL", config.nftSymbol);
        vm.serializeUint("Network config JSON", "07_MINT_PRICE", config.mintPrice);
        vm.serializeUint("Network config JSON", "08_MINT_START_BLOCK", config.mintStartBlock);
        vm.serializeUint("Network config JSON", "09_REVEAL_TYPE", config.revealType == RevealType.InCollection ? 0 : 1);
        vm.writeJson(vm.serializeUint("Network config JSON", "10_REVEAL_START_BLOCK", config.revealStartBlock), path);
    }

    /**
     * @dev Helper modifier to print events.
     */
    modifier printEvents() {
        vm.recordLogs();
        _;
        console.log("----------------------------------------");
        VmSafe.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i = 0; i < logs.length; i++) {
            console.log("Log ", i);
            console.log("Emitter: ", logs[i].emitter);
            console.log("Topics");
            for (uint256 j = 0; j < logs[i].topics.length; j++) {
                console.logBytes32(logs[i].topics[j]);
            }
            console.log("Data");
            console.logBytes(logs[i].data);
            console.log("----------------------------------------");
        }
    }
}
