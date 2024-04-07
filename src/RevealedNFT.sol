// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// External imports
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {ERC721Upgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";

// Internal imports
import {IRevealedNFT} from "./interfaces/IRevealedNFT.sol";
import {ReentrancyLock} from "src/utils/ReentrancyLock.sol";
import {IdSeed} from "src/utils/IdGenerator.sol";
import {Config} from "src/objects/Config.sol";
import {Call} from "src/utils/Call.sol";

contract RevealedNFT is IRevealedNFT, ERC721Upgradeable, OwnableUpgradeable {
    IdSeed private constant _ID_GENERATOR = IdSeed.wrap(keccak256("src.NFT.v1"));

    address private immutable _ORIGINAL_NFT;

    modifier onlyOriginalNFT() {
        require(msg.sender == _ORIGINAL_NFT, "RevealedNFT: Only original NFT contract can call");
        _;
    }

    constructor() {
        _ORIGINAL_NFT = msg.sender;
    }

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
    function mint(address to_, uint256 tokenId_) external override onlyOriginalNFT {
        _mint(to_, tokenId_);
    }
}
