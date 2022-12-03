// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/SoulHub.sol";

contract SoulHubTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    SoulHub public soulHub;
    address sender = vm.addr(0x1);
    address holder = vm.addr(0x2);
    string name = "Soul bits";
    string symbol = "SOBI";
    string baseImageURI = "ipfs://Qmag3irqBk2iKNTJuJrD1yEeaygCkD1yRFRnivyPQzTtiC/";
    SoulHub.Traits traits = SoulHub.Traits("online", "beloved", "trusted", "shine", "community");

    function encodeError(string memory error) internal pure returns (bytes memory encoded) {
        encoded = abi.encodeWithSignature(error);
        // abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function setUp() public {
        soulHub = new SoulHub(name, symbol);
        soulHub.setBaseImageURI(baseImageURI);
        vm.deal(sender, 1 ether);
    }

    function testOwner() public {
        assertEq(soulHub.owner(), address(this));
    }

    function testSetEra() public {
        soulHub.setEra("nascent");
        assertEq(soulHub.getEra(), "nascent");
    }

    function testNameAndSymbol() public {
        assertEq(soulHub.name(), name);
        assertEq(soulHub.symbol(), symbol);
    }

    function testGetMintPrice() public {
        assertEq(soulHub.getMintPrice(), 0.001 ether);
    }

    function testUpdateMintPrice() public {
        soulHub.updateMintPrice(1 ether);
        assertEq(soulHub.getMintPrice(), 1 ether);
    }

    function testFailUpdateMintPriceNotOwner() public {
        vm.prank(sender);
        soulHub.updateMintPrice(1 ether);
    }

    function testCannotMintWithInvalidPrice() public {
        vm.expectRevert(encodeError("SentAmountNotEqualMintPrice()"));
        soulHub.mintToken(holder, traits);
    }

    function testSetBaseImageURI() public {
        soulHub.setBaseImageURI("baseImageURI");
        assertEq(soulHub.getBaseImageURI(), "baseImageURI");
    }

    function testGetImageURI() public {
        soulHub.setBaseImageURI(baseImageURI);
        soulHub.setEra("nascent");
        SoulHub.Traits memory _traits = SoulHub.Traits("zoom", "funny", "trusted", "shine", "business");
        assertEq(
            string(soulHub.getImageURI(_traits)),
            "ipfs://Qmag3irqBk2iKNTJuJrD1yEeaygCkD1yRFRnivyPQzTtiC/nascent/14111.png"
        );
        _traits = SoulHub.Traits("lover", "hated", "critical", "halo", "state");
        assertEq(
            string(soulHub.getImageURI(_traits)),
            "ipfs://Qmag3irqBk2iKNTJuJrD1yEeaygCkD1yRFRnivyPQzTtiC/nascent/77711.png"
        );
        _traits = SoulHub.Traits("colleague", "unpleasant", "unsafe", "blaze", "press");
        assertEq(
            string(soulHub.getImageURI(_traits)),
            "ipfs://Qmag3irqBk2iKNTJuJrD1yEeaygCkD1yRFRnivyPQzTtiC/nascent/44411.png"
        );
    }

    function testMintBit() public {
        uint256 newTokenId = soulHub.totalSupply() + 1;
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), holder, newTokenId);
        vm.prank(sender);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
    }

    function testGetValidTokensInfo() public {
        address sender2 = vm.addr(0x10);
        vm.deal(sender2, 1 ether);
        address holder2 = vm.addr(0x20);

        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        vm.prank(sender);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        vm.prank(sender2);
        soulHub.mintToken{value: 0.001 ether}(holder2, traits);
        assertEq(soulHub.totalSupply(), 3);
        assertEq(soulHub.totalOwners(), 2);
        assertEq(soulHub.balanceOf(holder), 2);
        assertEq(soulHub.balanceOf(holder2), 1);
        assertEq(soulHub.ownerOf(1), holder);
        assertEq(soulHub.ownerOf(2), holder);
        assertEq(soulHub.ownerOf(3), holder2);
        assertEq(soulHub.senderOf(1), address(this));
        assertEq(soulHub.senderOf(2), address(sender));
        assertEq(soulHub.senderOf(3), address(sender2));
    }

    function testCannotTransferSBT() public {
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        uint256 tokenId = soulHub.tokenOfOwnerByIndex(holder, 0);
        vm.prank(holder);
        vm.expectRevert(encodeError("TokenIsSoulBound()"));
        soulHub.safeTransferFrom(holder, sender, tokenId);
    }

    function testfetchSenderTokens() public {
        vm.startPrank(sender);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        vm.stopPrank();
        soulHub.mintToken{value: 0.001 ether}(holder, traits);

        uint256[] memory tokens = soulHub.fetchSenderTokens(sender);
        assertEq(tokens.length, 3);
        for (uint256 i; i < tokens.length; i++) {
            assertEq(tokens[i], i + 1);
        }
    }

    function testfetchOwnerTokens() public {
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);
        soulHub.mintToken{value: 0.001 ether}(holder, traits);

        address holder2 = vm.addr(0x20);
        soulHub.mintToken{value: 0.001 ether}(holder2, traits);

        vm.prank(holder);
        uint256[] memory tokens = soulHub.fetchOwnerTokens(holder);
        assertEq(tokens.length, 3);
        for (uint256 i; i < tokens.length; i++) {
            assertEq(tokens[i], i + 1);
        }
    }
}
