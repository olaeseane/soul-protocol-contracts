// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/SoulHub.sol";

contract SoulHubScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        SoulHub soulHub = new SoulHub("Soul bits", "SOULBITS");

        soulHub.setBaseImageURI("ipfs://Qmag3irqBk2iKNTJuJrD1yEeaygCkD1yRFRnivyPQzTtiC/");
        soulHub.setEra("nascent");
        SoulHub.Traits memory traits = SoulHub.Traits("online", "beloved", "trusted", "shine", "community");
        soulHub.mintToken(0x5f6939026c7944A8ca09752039AD30F34c2B7baA, traits);
        traits = SoulHub.Traits("colleague", "nice", "solid", "halo", "business");
        soulHub.mintToken(0x5f6939026c7944A8ca09752039AD30F34c2B7baA, traits);
        traits = SoulHub.Traits("lover", "hated", "critical", "empty", "celebrity");
        soulHub.mintToken(0x5f6939026c7944A8ca09752039AD30F34c2B7baA, traits);

        vm.stopBroadcast();
    }
}
