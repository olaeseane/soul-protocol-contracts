// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/SoulHub.sol";

contract SoulHubScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(deployerPrivateKey);

        address addrSoulHub = 0xd971A8147314118bc930cA88E729F1760e1a938b;
        SoulHub soulHub = SoulHub(addrSoulHub);

        SoulHub.Traits memory traits = SoulHub.Traits("colleague", "unpleasant", "unsafe", "blaze", "press");
        soulHub.mintToken(0x34C064b128237DB2B917962c45083Ef140564bD8, traits);

        vm.stopBroadcast();
    }
}
