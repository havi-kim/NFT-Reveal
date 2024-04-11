// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1967Proxy} from "@openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {Config} from "src/objects/Config.sol";
import {RevealType} from "src/types/GlobalEnum.sol";
import {PurchasableNFT} from "src/PurchasableNFT.sol";
import {RevealedNFT, IRevealedNFT} from "src/RevealedNFT.sol";
import {CollectionError} from "src/errors/Error.sol";

library SeparateCollection {
    bytes32 private constant _REVEAL_STORAGE = keccak256("src.objects.SeparateCollectionReveal.storage.v1");

    struct RevealStorage {
        IRevealedNFT revealedNFT;
    }

    /**
     * @dev Create the revealed NFT contract.
     * @param name_ The name of the NFT.
     * @param symbol_ The symbol of the NFT.
     * @param owner_ The address of the owner.
     */
    function createRevealedNFT(string memory name_, string memory symbol_, address owner_) internal {
        RevealStorage storage data = read();
        if (address(data.revealedNFT) != address(0)) {
            revert CollectionError.CollectionAlreadyCreated(address(data.revealedNFT));
        }

        address impl = address(new RevealedNFT());
        bytes memory initData = abi.encodeWithSelector(IRevealedNFT.initialize.selector, name_, symbol_, owner_);
        data.revealedNFT = IRevealedNFT(address(new ERC1967Proxy(impl, initData)));
    }

    /**
     * @dev Mint a revealed NFT.
     * @param to_ The address of the receiver.
     * @param tokenId_ The token ID.
     * @param metadata_ The metadata of the NFT.
     */
    function mint(address to_, uint256 tokenId_, uint256 metadata_) internal {
        RevealStorage storage data = read();
        if (address(data.revealedNFT) == address(0)) {
            revert CollectionError.CollectionNotCreated();
        }
        data.revealedNFT.mint(to_, tokenId_, metadata_);
    }

    /**
     * @dev Get the reveal contract.
     * @return The reveal contract.
     */
    function getRevealedNFT() internal view returns (IRevealedNFT) {
        return read().revealedNFT;
    }

    /**
     * @dev Check if the revealed NFT is created.
     * @return True if the revealed NFT is created.
     */
    function isRevealedNFTCreated() internal view returns (bool) {
        return address(read().revealedNFT) != address(0);
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
