// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";

import "./BytesLib.sol";
import {ERC721} from "./ERC721.sol";
import "./IWormhole.sol";

contract WormholeNFT is ERC721, Owned {
    using BytesLib for bytes;

    struct State {
        // wormhole core contract address and chainId
        address payable wormhole;
        uint16 chainId;
        // mapping of consumed token transfers
        mapping(bytes32 => bool) completedTransfers;
        // mapping of NFT contracts on other chains
        mapping(uint16 => bytes32) nftContracts;
    }

    struct WHTransfer {
        // PayloadID uint8 = 1
        // TokenID of the token
        uint256 tokenId;
        // Address of the recipient. Left-zero-padded if shorter than 32 bytes
        bytes32 to;
        // Chain ID of the recipient
        uint16 toChain;
    }

    State public _wormholeState;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Owned(msg.sender) {}

    // wormhole core contract
    function setWormhole(address wh) public {
        _wormholeState.wormhole = payable(wh);
    }

    function wormhole() public view returns (IWormhole) {
        return IWormhole(_wormholeState.wormhole);
    }

    // chain id
    function setChainId(uint16 _chainId) public {
        _wormholeState.chainId = _chainId;
    }

    function chainId() public view returns (uint16) {
        return _wormholeState.chainId;
    }

    // NFT contracts on other chains
    function setNftContract(uint16 _chainId, bytes32 _nftContract) public {
        _wormholeState.nftContracts[_chainId] = _nftContract;
    }

    function nftContract(uint16 _chainId) public view returns (bytes32) {
        return _wormholeState.nftContracts[_chainId];
    }

    // consumed token transfers
    function _setTransferCompleted(bytes32 hash) internal {
        _wormholeState.completedTransfers[hash] = true;
    }

    function isTransferCompleted(bytes32 hash) public view returns (bool) {
        return _wormholeState.completedTransfers[hash];
    }

    // transfer nft to other chain
    function wormholeTransfer(uint256 tokenID, uint16 recipientChain, bytes32 recipient, uint32 nonce)
        public
        payable
        onlyOwner
        returns (uint64 sequence)
    {
        _burn(tokenID);

        require(nftContract(recipientChain) != 0, "recipientChain not allowed");
        bytes memory encoded = abi.encodePacked(uint8(1), tokenID, recipient, recipientChain);
        sequence = wormhole().publishMessage{value: msg.value}(nonce, encoded, 15);
    }

    // get nft from oher chain through Wormhole
    function wormholeCompleteTransfer(bytes memory encodedVm) public {
        // (address to, uint256 tokenId) = _wormholeCompleteTransfer(encodedVm);

        (IWormhole.VM memory vm, bool valid, string memory reason) = wormhole().parseAndVerifyVM(encodedVm);

        require(valid, reason);
        require(nftContract(vm.emitterChainId) != vm.emitterAddress, "invalid emitter");
        require(!isTransferCompleted(vm.hash), "transfer already completed");

        WHTransfer memory transfer = _parseTransfer(vm.payload);

        _setTransferCompleted(vm.hash);

        require(transfer.toChain == chainId(), "invalid target chain");

        _safeMint(address(uint160(uint256(transfer.to))), transfer.tokenId);
    }

    function _parseTransfer(bytes memory encoded) internal pure returns (WHTransfer memory transfer) {
        uint256 index = 0;

        uint8 payloadId = encoded.toUint8(index);
        index += 1;

        require(payloadId == 1, "invalid transfer");

        transfer.tokenId = encoded.toUint256(index);
        index += 32;

        transfer.to = encoded.toBytes32(index);
        index += 32;

        transfer.toChain = encoded.toUint16(index);
        index += 2;

        require(encoded.length == index, "invalid transfer");
        return transfer;
    }
}
