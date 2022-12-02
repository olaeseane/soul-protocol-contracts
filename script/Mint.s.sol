// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/SoulHub.sol";

contract SoulHubScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address addrSoulHub = 0xF1a366d16686Ca5dF7D86aa49b40dBeAc8a7409C;
        SoulHub soulHub = SoulHub(addrSoulHub);

        SoulHub.Traits memory traits = SoulHub.Traits("colleague", "unpleasant", "unsafe", "blaze", "press");
        soulHub.mintToken(0xE7Ca90149B323E6D9DB6ae68Cf9B97694c2B3Ab3, traits);

        vm.stopBroadcast();
    }
}
