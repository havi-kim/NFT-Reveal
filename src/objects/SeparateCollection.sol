// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1967Proxy} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {Config} from "src/objects/Config.sol";
import {RevealType} from "src/types/GlobalEnum.sol";
import {NFT} from "../NFT.sol";
import {RevealedNFT, IRevealedNFT} from "../RevealedNFT.sol";

library SeparateCollection {
    bytes32 private constant _REVEAL_STORAGE = keccak256("src.objects.SeparateCollectionReveal.storage.v1");

    struct RevealStorage {
        address revealContract;
    }

    /**
     * @dev Separate the reveal NFT contract.
     * @param name_ The name of the NFT.
     * @param symbol_ The symbol of the NFT.
     * @param owner_ The address of the owner.
     */
    function separateRevealNFT(string memory name_, string memory symbol_, address owner_) internal {
        RevealStorage storage data = read();
        if (data.revealContract != address(0)) {
            revert("Reveal: Already created");
        }

        address impl = address(new RevealedNFT());
        bytes memory initData = abi.encodeWithSelector(IRevealedNFT.initialize.selector, name_, symbol_, owner_);
        data.revealContract = address(new ERC1967Proxy(impl, initData));
    }

    /**
     * @dev Mint a revealed NFT.
     * @param to_ The address of the receiver.
     * @param tokenId_ The token ID.
     * @param metadata_ The metadata of the NFT.
     */
    function mint(address to_, uint256 tokenId_, uint256 metadata_) internal {
        IRevealedNFT(read().revealContract).mint(to_, tokenId_, metadata_);
    }

    /**
     * @dev Get the reveal contract.
     * @return The reveal contract.
     */
    function revealContract() internal view returns (address) {
        return read().revealContract;
    }

    /**
     * @dev Read the storage slot of the Reveal. If change visibility of this function to internal, encapsulation will break.
     * @return data The storage slot of the Reveal.
     */
    function read() private pure returns (RevealStorage storage data) {
        bytes32 key = _REVEAL_STORAGE;
        assembly {
            data.slot := key
        }
    }
}
