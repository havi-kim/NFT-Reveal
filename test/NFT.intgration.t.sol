// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/vrf/VRFCoordinatorV2Interface.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "src/NFT.sol";
import "src/RevealedNFT.sol";

// This is a integration test. If dependencies are needed, use `forge test -f rpc` to run the test.
contract NFTIntegrationTest is Test {
    bool private isForked = false;

    uint96 private mintPrice = 0.1 ether;
    address private mockCoordinator = address(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);

    address private owner = address(0x1);
    address private user0 = address(0x2);
    address private user1 = address(0x3);

    function setUp() public {
        string memory rpc = vm.envOr("FORK_RPC", string(""));
        if (bytes(rpc).length > 0) {
            isForked = true;
            vm.createSelectFork(rpc);
        }

        Call.pay(owner, 10 ether);
        Call.pay(user0, 10 ether);
        Call.pay(user1, 10 ether);
    }

    // @success_test
    function test_case_user_sequence_InCollection() external {

        // Deploy contract
        address impl = address(new NFT());

        // Initialize NFT contract
        vm.broadcast(owner);
        bytes memory initData = abi.encodeWithSelector(
            NFT.initialize.selector,
            "TEST_NAME",
            "TEST_SYMBOL",
            mockCoordinator,
            mintPrice,
            uint48(block.number + 1),
            RevealType.InCollection,
            uint48(block.number + 100)
        );
        NFT nftContract = NFT(address(new ERC1967Proxy(impl, initData)));

        if (isForked) {
            vm.broadcast(0x58311Bf48BCfDF069cA28ed46f7953837175BAB4);
            ICoordinator(mockCoordinator).addConsumer(10881, address(nftContract));
        }

        // Test initialize
        assertEq(nftContract.owner(), address(owner), "The contract owner is not set correctly");

        // Block number increment after start mint
        vm.roll(block.number + 1);

        // User0 mint NFT
        vm.broadcast(user0);
        uint256 tokenId = nftContract.mint{value: mintPrice}();
        // Test mint
        assertEq(nftContract.ownerOf(tokenId), address(user0), "The NFT owner shold be user0");

        // Block number increment after start reveal
        vm.roll(block.number + 100);

        // User0 reveal the nft
        vm.broadcast(user0);
        // If test is run without fork, the mockCall is needed.
        if (!isForked) {
            vm.mockCall(
                mockCoordinator,
                abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
                abi.encode(1)
            );
        }
        uint256 requestId = nftContract.reveal(tokenId);
        // Test start reveal
        assertTrue(
            nftContract.revealStatus(tokenId) == RevealStatus.InProgress, "The reveal status is not in progress"
        );

        // Coordinator fulfill the random words
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = uint256(0x300020001000a001400);
        vm.broadcast(mockCoordinator);
        nftContract.rawFulfillRandomWords(requestId, randomWords);
        // Test end reveal
        assertTrue(nftContract.revealStatus(tokenId) == RevealStatus.Revealed, "The reveal status is not revealed");
        assertEq(
            nftContract.tokenURI(tokenId),
            '{"name": "The revealed NFT-1", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}',
            "The token URI is not set correctly"
        );
    }

    // @success_test
    function test_case_user_sequence_SeparateCollection() external {
        // Deploy contract
        address impl = address(new NFT());

        // Initialize NFT contract
        vm.broadcast(owner);
        bytes memory initData = abi.encodeWithSelector(
            NFT.initialize.selector,
            "TEST_NAME",
            "TEST_SYMBOL",
            mockCoordinator,
            mintPrice,
            uint48(block.number + 1),
            RevealType.SeparateCollection,
            uint48(block.number + 100)
        );
        NFT nftContract = NFT(address(new ERC1967Proxy(impl, initData)));

        if (isForked) {
            vm.broadcast(0x58311Bf48BCfDF069cA28ed46f7953837175BAB4);
            ICoordinator(mockCoordinator).addConsumer(10881, address(nftContract));
        }

        // Test initialize
        assertEq(nftContract.owner(), address(owner), "The contract owner is not set correctly");

        // Block number increment after start mint
        vm.roll(block.number + 1);

        // User0 mint NFT
        vm.broadcast(user0);
        uint256 tokenId = nftContract.mint{value: mintPrice}();
        // Test mint
        assertEq(nftContract.ownerOf(tokenId), address(user0), "The NFT owner shold be user0");

        // Block number increment after start reveal
        vm.roll(block.number + 100);

        // User0 reveal the nft
        vm.broadcast(user0);
        // If test is run without fork, the mockCall is needed.
        if (!isForked) {
            vm.mockCall(
                mockCoordinator,
                abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
                abi.encode(1)
            );
        }
        uint256 requestId = nftContract.reveal(tokenId);
        // Test start reveal
        assertTrue(
            nftContract.revealStatus(tokenId) == RevealStatus.InProgress, "The reveal status is not in progress"
        );

        // Coordinator fulfill the random words
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = uint256(0x300020001000a001400);
        vm.broadcast(mockCoordinator);
        nftContract.rawFulfillRandomWords(requestId, randomWords);
        // Test end reveal
        RevealedNFT revealedNFT = RevealedNFT(nftContract.revealedNFT());
        assertTrue(nftContract.revealStatus(tokenId) == RevealStatus.Revealed, "The reveal status is not revealed");
        assertEq(
            revealedNFT.tokenURI(tokenId),
            '{"name": "The revealed NFT-1", "stats": {"strength": 20, "intelligence": 10, "wisdom": 1, "charisma": 2, "dexterity": 3}}',
            "The token URI is not set correctly"
        );
    }

    // @sucess_test
    function test_upgrade() external {
        address nftImpl = address(new NFT());
        address revealedNFTImpl = address(new RevealedNFT());

        // Initialize NFT contract
        vm.broadcast(owner);
        bytes memory initData = abi.encodeWithSelector(
            NFT.initialize.selector,
            "TEST_NAME",
            "TEST_SYMBOL",
            mockCoordinator,
            mintPrice,
            uint48(block.number + 1),
            RevealType.SeparateCollection,
            uint48(block.number + 100)
        );

        NFT nftContract = NFT(address(new ERC1967Proxy(nftImpl, initData)));
        vm.broadcast(owner);
        nftContract.createRevealedNFT();
        RevealedNFT revealedNFT = RevealedNFT(nftContract.revealedNFT());

        // Upgrade NFT contract to RevealedNFT contract
        vm.broadcast(owner);
        nftContract.upgradeToAndCall(revealedNFTImpl, "");

        // Upgrade RevealedNFT contract to NFT contract
        vm.broadcast(owner);
        revealedNFT.upgradeToAndCall(nftImpl, "");
    }
}

interface ICoordinator {
    function addConsumer(uint64 subId, address consumer) external;
}
