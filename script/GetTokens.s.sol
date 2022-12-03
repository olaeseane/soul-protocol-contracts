// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/SoulHub.sol";

import {console} from "forge-std/console.sol";

contract SoulHubScript is Script {
    function run() external view {
        address addrSoulHub = 0xF1a366d16686Ca5dF7D86aa49b40dBeAc8a7409C;
        SoulHub soulHub = SoulHub(addrSoulHub);

        string memory uri = soulHub.tokenURI(2);
        console.log(uri);
    }
}
