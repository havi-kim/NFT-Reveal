// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// External imports
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {VRFConsumerBaseV2Upgradeable} from "@chainlink-contracts/dev/VRFConsumerBaseV2Upgradeable.sol";

// Internal imports
import {ReentrancyLock, UsingReentrancyLock} from "src/utils/ReentrancyLock.sol";
import {IdSeed} from "src/utils/IdGenerator.sol";
import {Config} from "src/objects/Config.sol";
import {Call} from "src/utils/Call.sol";
import {ChainlinkVRFSepolia} from "src/utils/ChainlinkVRFSepolia.sol";
import {Reveal} from "src/objects/Reveal.sol";
import {RevealType} from "src/types/GlobalEnum.sol";
import {Metadata} from "src/objects/Metadata.sol";
import {SeparateCollection} from "src/objects/SeparateCollection.sol";
import {RevealStatus} from "src/types/GlobalEnum.sol";

contract NFT is
    UUPSUpgradeable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    VRFConsumerBaseV2Upgradeable,
    UsingReentrancyLock
{
    //--------------------------------------------------------------------------------------
    //------------------------------------  CONSTANT  --------------------------------------
    //--------------------------------------------------------------------------------------

    // The key of the ID generator
    IdSeed private constant _ID_GENERATOR = IdSeed.wrap(keccak256("src.NFT.v1"));

    //--------------------------------------------------------------------------------------
    //----------------------------  STATE-CHANGING FUNCTIONS  ------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Initialize the contract.
     * @param name_ The name of the NFT.
     * @param symbol_ The symbol of the NFT.
     * @param vrfCoordinator_ The address of the VRF coordinator.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address vrfCoordinator_,
        uint96 mintPrice_,
        uint48 mintStartBlock_,
        RevealType revealType_,
        uint48 revealStartBlock_
    ) external initializer {
        __ERC721_init(name_, symbol_);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __VRFConsumerBaseV2_init(vrfCoordinator_);
        Config.init(mintPrice_, mintStartBlock_, revealType_, revealStartBlock_);
    }

    /**
     * @dev Mint a NFT. The minting price is determined by the Config.
     *      The minting is only possible after the minting has started and before the reveal has started.
     *      If the payment is more than the minting price, the surplus will be refunded.
     *      The token ID is generated incrementally.
     *      The reentrancy is locked during the minting. Because refunding the surplus may call the external contract.
     */
    function mint() external payable nonReentrant returns (uint256 tokenId) {
        // 0. Check if mint possible
        {
            if (!Config.isMintStarted()) {
                revert("mint: Minting has not started yet");
            }
            if (Config.isRevealStarted()) {
                revert("mint: Reveal has already started");
            }
        }

        // 1. Check if the payment is sufficient. If surplus, refund it.
        {
            uint256 mintingPrice = Config.mintPrice();
            if (msg.value < mintingPrice) {
                revert("mint: Insufficient payment");
            }
            if (msg.value > mintingPrice) {
                Call.pay(msg.sender, msg.value - mintingPrice);
            }
        }

        // 2. Generate a unique token ID
        tokenId = _ID_GENERATOR.generateUniqueIncrementalId();

        // 3. Mint the token
        _mint(msg.sender, tokenId);
    }

    /**
     * @dev Reveal a NFT. The reveal is only possible after the reveal has started.
     */
    function reveal(uint256 tokenId_) external nonReentrant returns (uint256 requestId) {
        // 0. Check if reveal possible
        {
            if (!Config.isRevealStarted()) {
                revert("reveal: Reveal has not started yet");
            }
        }

        // 1. Request a random number & start the reveal
        {
            requestId = ChainlinkVRFSepolia.request(1);
            Reveal.startReveal(tokenId_, requestId);
        }

        // 2. Create the revealed NFT contract if needed
        if (Config.revealType() == RevealType.SeparateCollection && !SeparateCollection.isRevealedNFTCreated()) {
            SeparateCollection.createRevealedNFT(name(), symbol(), owner());
        }
    }

    //--------------------------------------------------------------------------------------
    //---------------------------------  ADMIN FUNCTIONS  ---------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Create the revealed NFT contract. Only available in SeparateCollection config.
     */
    function createRevealedNFT() external onlyOwner returns (address) {
        if (Config.revealType() != RevealType.SeparateCollection) {
            revert("createRevealedNFT: Only available in SeparateCollection config");
        }
        SeparateCollection.createRevealedNFT(name(), symbol(), owner());
        return address(SeparateCollection.getRevealedNFT());
    }

    /**
     * @dev Withdraw the balance of the contract.
     * @param amount_ The amount to withdraw.
     */
    function withdraw(uint256 amount_) external onlyOwner {
        if (amount_ > address(this).balance) {
            amount_ = address(this).balance;
        }
        Call.pay(msg.sender, amount_);
    }

    /**
     * @dev Set the mint price.
     * @param price_ The mint price.
     */
    function setMintPrice(uint96 price_) external onlyOwner {
        Config.setMintPrice(price_);
    }

    /**
     * @dev Set the mint start block.
     * @param startBlock_ The mint start block.
     */
    function setMintStartBlock(uint48 startBlock_) external onlyOwner {
        Config.setMintStartBlock(startBlock_);
    }

    /**
     * @dev Set the reveal type.
     * @param revealType_ The reveal type.
     */
    function setRevealType(RevealType revealType_) external onlyOwner {
        Config.setRevealType(revealType_);
    }

    /**
     * @dev Set the reveal start block.
     * @param startBlock_ The reveal start block.
     */
    function setRevealStartBlock(uint48 startBlock_) external onlyOwner {
        Config.setRevealStartBlock(startBlock_);
    }

    //--------------------------------------------------------------------------------------
    //--------------------------------------  GETTER  --------------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Get Config.
     */
    function config() external view returns (Config.ConfigStorage memory) {
        return Config.copy();
    }

    /**
     * @dev Get the token URI.
     * @return The token URI.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return Metadata.getMetadata(tokenId);
    }

    /**
     * @dev Get the revealed NFT address.
     * @return The revealed NFT address.
     */
    function revealedNFT() external view returns (address) {
        return address(SeparateCollection.getRevealedNFT());
    }

    function revealStatus(uint256 tokenId) external view returns (RevealStatus) {
        return Reveal.status(tokenId);
    }

    //--------------------------------------------------------------------------------------
    //-------------------------------  INTERNAL FUNCTIONS   --------------------------------
    //--------------------------------------------------------------------------------------

    /**
     * @dev Callback function used by VRF Coordinator.
     * @param requestId_ The request ID.
     * @param randomWords_ The random words.
     */
    function fulfillRandomWords(uint256 requestId_, uint256[] memory randomWords_) internal override {
        // 0. End the reveal
        (uint256 tokenId, address to) = Reveal.endReveal(requestId_);

        // 1. Get the reveal type
        RevealType revealType = Config.revealType();

        // 2. If the reveal type is InCollection, set the metadata
        if (revealType == RevealType.InCollection) {
            Metadata.setMetadata(tokenId, randomWords_[0]);
            return;
        }

        // 3. If the reveal type is SeparateCollection, mint the revealed NFT
        if (revealType == RevealType.SeparateCollection) {
            SeparateCollection.mint(to, tokenId, randomWords_[0]);
            return;
        }

        // 4. If the reveal type is not supported, revert
        revert("fulfillRandomWords: Invalid reveal type");
    }

    /**
     * @dev Authorize the upgrade. Only the owner can authorize the upgrade.
     * @param newImplementation The address of the new implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
