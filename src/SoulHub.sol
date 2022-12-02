// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-contracts/utils/Base64.sol";

import {ERC721} from "./ERC721.sol";

// import {console} from "forge-std/console.sol";

contract SoulHub is ERC721, Owned {
    error SentAmountNotEqualMintPrice();
    error TokensNotExist();

    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _mintPrice = 0.001 ether;

    mapping(uint256 => address) private _senderOf;

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _owners;

    string private _baseImageURI;

    string private _era;

    struct Traits {
        string familiarity;
        string liking;
        string solidity;
        string shining;
        string rarity;
    }

    mapping(string => mapping(string => string)) private _codes;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Owned(msg.sender) {
        _codes["familiarity"]["online"] = "1";
        _codes["familiarity"]["zoom"] = "1";
        _codes["familiarity"]["buddy"] = "4";
        _codes["familiarity"]["colleague"] = "4";
        _codes["familiarity"]["friend"] = "4";
        _codes["familiarity"]["family"] = "7";
        _codes["familiarity"]["lover"] = "7";

        _codes["liking"]["beloved"] = "1";
        _codes["liking"]["nice"] = "1";
        _codes["liking"]["funny"] = "4";
        _codes["liking"]["obscure"] = "4";
        _codes["liking"]["unpleasant"] = "4";
        _codes["liking"]["nasty"] = "7";
        _codes["liking"]["hated"] = "7";

        _codes["solidity"]["trusted"] = "1";
        _codes["solidity"]["solid"] = "1";
        _codes["solidity"]["safe"] = "4";
        _codes["solidity"]["unsafe"] = "4";
        _codes["solidity"]["risky"] = "7";
        _codes["solidity"]["critical"] = "7";

        _codes["shining"]["empty"] = "0";
        _codes["shining"]["shine"] = "1";
        _codes["shining"]["blaze"] = "1";
        _codes["shining"]["halo"] = "1";

        _codes["rarity"]["community"] = "0";
        _codes["rarity"]["press"] = "1";
        _codes["rarity"]["guild/DAO"] = "1";
        _codes["rarity"]["business"] = "1";
        _codes["rarity"]["partner"] = "1";
        _codes["rarity"]["celebrity"] = "1";
        _codes["rarity"]["state"] = "1";
    }

    function updateMintPrice(uint256 newPrice) external onlyOwner {
        _mintPrice = newPrice;
    }

    function getMintPrice() public view returns (uint256) {
        return _mintPrice;
    }

    function mintToken(address _to, Traits calldata traits) public payable {
        // if (msg.value != _mintPrice) {
        //     revert SentAmountNotEqualMintPrice();
        // }

        uint256 newTokenId = totalSupply() + 1; // todo: if totalSupply > type(uint).MAX
        string memory image = string(getImageURI(traits));
        string memory uri = getTokenURI(image, traits);

        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, uri);

        _senderOf[newTokenId] = msg.sender;
        _owners.add(_to);
    }

    function getTokenURI(string memory _image, Traits calldata _traits) public view returns (string memory) {
        bytes memory dataURI;
        {
            dataURI = abi.encodePacked("{" '"image": "', _image, '","attributes": [');
        }
        {
            dataURI = abi.encodePacked(dataURI, '{"trait_type": "Familiarity", "value": "', _traits.familiarity, '"},');
        }
        {
            dataURI = abi.encodePacked(dataURI, "{", '"trait_type": "Liking", "value": "', _traits.liking, '"},');
        }
        {
            dataURI = abi.encodePacked(dataURI, "{", '"trait_type": "Solidity", "value": "', _traits.solidity, '"},');
        }
        {
            dataURI = abi.encodePacked(dataURI, "{", '"trait_type": "Shining", "value": "', _traits.shining, '"},');
        }
        {
            dataURI = abi.encodePacked(dataURI, "{", '"trait_type": "Rarity", "value": "', _traits.rarity, '"},');
        }
        {
            dataURI = abi.encodePacked(dataURI, "{", '"trait_type": "Era", "value": "', _era, '"}]}');
        }

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function getImageURI(Traits calldata _traits) public view returns (bytes memory imageURI) {
        {
            imageURI = bytes.concat(bytes(_baseImageURI), bytes(_era), "/");
        }
        {
            imageURI = bytes.concat(
                imageURI, bytes(_codes["familiarity"][_traits.familiarity]), bytes(_codes["liking"][_traits.liking])
            );
        }
        {
            imageURI = bytes.concat(
                imageURI, bytes(_codes["solidity"][_traits.solidity]), bytes(_codes["shining"][_traits.shining])
            );
        }
        {
            imageURI = bytes.concat(imageURI, bytes(_codes["rarity"][_traits.rarity]), bytes(".png"));
        }
    }

    function setBaseImageURI(string calldata uri) public onlyOwner {
        _baseImageURI = uri;
    }

    function getBaseImageURI() public view returns (string memory) {
        return _baseImageURI;
    }

    function setEra(string calldata newEra) public {
        _era = newEra;
    }

    function getEra() public view returns (string memory) {
        return _era;
    }

    function senderOf(uint256 id) public view returns (address sender) {
        sender = _senderOf[id];
        if (sender == address(0)) {
            revert TokensNotExist();
        }
    }

    function totalOwners() public view returns (uint256) {
        return _owners.length();
    }

    function fetchSenderTokens(address _sender) public view returns (uint256[] memory) {
        if (totalSupply() == 0) {
            revert TokensNotExist();
        }
        uint256 tokenCount = totalSupply();
        uint256 senderTokenCount;

        for (uint256 id = 1; id <= tokenCount; id++) {
            if (_senderOf[id] == _sender) senderTokenCount++;
        }

        uint256[] memory senderTokenIds = new uint[](senderTokenCount);
        uint256 index;
        for (uint256 id = 1; id <= tokenCount; id++) {
            if (_senderOf[id] == _sender) {
                senderTokenIds[index] = id;
                index++;
            }
        }

        return senderTokenIds;
    }

    function fetchOwnerTokens() public view returns (uint256[] memory) {
        uint256 ownerTokenCount = _balanceOf[msg.sender].length();
        uint256[] memory ownerTokenIds = new uint[](ownerTokenCount);

        for (uint256 i; i < ownerTokenCount; i++) {
            ownerTokenIds[i] = _balanceOf[msg.sender].at(i);
        }
        return ownerTokenIds;
    }
}
