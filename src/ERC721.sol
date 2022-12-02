// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "openzeppelin-contracts/utils/structs/EnumerableMap.sol";
import "openzeppelin-contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-contracts/utils/Strings.sol";

// import {console} from "forge-std/console.sol";

abstract contract ERC721 {
    // ERRORS
    error TokenIsSoulBound();

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*
    * METADATA STORAGE/LOGIC
    */
    using Strings for uint256;

    string public name;
    string public symbol;

    mapping(uint256 => string) private _tokenURIs;
    // string private _baseURI;

    function tokenURI(uint256 id) public view virtual returns (string memory) {
        require(_exists(id), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[id];
        return _tokenURI;
    }

    function _setTokenURI(uint256 id, string memory _tokenURI) internal virtual {
        require(_exists(id), "ERC721Metadata: URI query for nonexistent token");
        _tokenURIs[id] = _tokenURI;
    }

    /*
     * ERC721 BALANCE/OWNER STORAGE
     */
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    // Mapping from owner address to their (enumerable) set of owned tokens
    mapping(address => EnumerableSet.UintSet) internal _balanceOf;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap internal _ownerOf;

    function ownerOf(uint256 id) public view virtual returns (address) {
        (bool ok, address owner) = _ownerOf.tryGet(id);
        require(ok, "ERC721: owner query for nonexistent token");
        return owner;
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balanceOf[owner].length();
    }

    function _exists(uint256 id) internal view virtual returns (bool) {
        return _ownerOf.contains(id);
    }

    /* 
    * ERC721 APPROVAL STORAGE
    */
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*    
    * ERC721 LOGIC
    */
    function approve(address spender, uint256 id) public virtual {
        (, address owner) = _ownerOf.tryGet(id);

        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "ERC721: approve caller is not owner nor approved for all"
        );

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address, address, uint256) public virtual {
        revert TokenIsSoulBound();

        /* require(from == _ownerOf.get(id), "ERC721: transfer from is not owner token id");

        require(to != address(0), "ERC721: transfer for the zero address");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "ERC721: transfer caller is not owner nor approved"
        );
        
        _balanceOf[from].remove(id);
        _balanceOf[to].add(id);

        _ownerOf.set(id, to);

        delete getApproved[id];

        emit Transfer(from, to, id);
        */
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual {
        transferFrom(from, to, id);
        /*
        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        */
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata) public virtual {
        transferFrom(from, to, id);
        /*
        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        */
    }

    /*
    * ERC165 LOGIC
    */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC165 Interface ID for ERC165
            || interfaceId == 0x80ac58cd // ERC165 Interface ID for ERC721
            || interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*
    * INTERNAL MINT/BURN LOGIC
    */
    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(id), "ERC721: token already minted");

        _balanceOf[to].add(id);
        _ownerOf.set(id, to);

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        require(_exists(id), "ERC72: burn for nonexistent token");

        address owner = _ownerOf.get(id);
        _balanceOf[owner].remove(id);
        _ownerOf.remove(id);

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /* 
    * IERC721Enumerable logic
    */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        return _balanceOf[owner].at(index);
    }

    function totalSupply() public view returns (uint256) {
        return _ownerOf.length();
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        (uint256 id,) = _ownerOf.at(index);
        return id;
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
