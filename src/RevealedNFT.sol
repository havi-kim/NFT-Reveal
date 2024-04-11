// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// External imports
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {ERC721Upgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Internal imports
import {IRevealedNFT} from "./interfaces/IRevealedNFT.sol";
import {ReentrancyLock} from "src/utils/ReentrancyLock.sol";
import {IdSeed} from "src/utils/IdGenerator.sol";
import {Config} from "src/objects/Config.sol";
import {Call} from "src/utils/Call.sol";
import {Metadata} from "src/objects/Metadata.sol";
import {RevealedNFTError} from "src/errors/Error.sol";

/**
 * @title Revealed NFT.
 * @dev The revealed NFT contract. It is a child contract of the parent NFT contract.
 */
contract RevealedNFT is IRevealedNFT, UUPSUpgradeable, ERC721Upgradeable, OwnableUpgradeable {
    //--------------------------------------------------------------------------------------
    //--------------------------------- CONSTANT & STATE  ----------------------------------
    //--------------------------------------------------------------------------------------

    // The address of the parent NFT contract
    address private immutable _PARENT_NFT;

    constructor() {
        _PARENT_NFT = msg.sender;
    }

    //--------------------------------------------------------------------------------------
    //----------------------------  STATE-CHANGING FUNCTIONS  ------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Initialize the contract.
     * @param name_ The name of the NFT.
     * @param symbol_ The symbol of the NFT.
     * @param owner_ The address of the owner.
     */
    function initialize(string memory name_, string memory symbol_, address owner_) public override initializer {
        __ERC721_init(name_, symbol_);
        __Ownable_init(owner_);
    }

    /**
     * @dev Mint a NFT.
     */
    function mint(address to_, uint256 tokenId_, uint256 metadata_) external override onlyParent {
        _mint(to_, tokenId_);
        Metadata.setMetadata(tokenId_, metadata_);
    }

    //--------------------------------------------------------------------------------------
    //--------------------------------------  GETTER  --------------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Get the token URI.
     * @return The token URI.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return Metadata.getMetadata(tokenId);
    }

    //--------------------------------------------------------------------------------------
    //-------------------------------  INTERNAL FUNCTIONS   --------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Authorize the upgrade. Only the owner can authorize the upgrade.
     * @param newImplementation The address of the new implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    //--------------------------------------------------------------------------------------
    //------------------------------------  MODIFIERS  -------------------------------------
    //--------------------------------------------------------------------------------------

    modifier onlyParent() {
        if (msg.sender != _PARENT_NFT) {
            revert RevealedNFTError.OnlyParentNFT(_PARENT_NFT, msg.sender);
        }
        _;
    }
}
