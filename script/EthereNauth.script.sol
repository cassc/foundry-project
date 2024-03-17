// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";

contract EtherNautScript is Script {
    address naut = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;

    function setUp() public{
        vm.createSelectFork("sepolia");
    }

    function submitLevelInstance(address instance) internal{
        naut.call(abi.encodeWithSignature("submitLevelInstance(address)", instance));
    }

    function createLevelInstance(address level) internal{
        // Ethernaut(naut).createLevelInstance(level);
        naut.call(abi.encodeWithSignature("createLevelInstance(address)", level));
    }

    function run() external{
        vm.startBroadcast();

        createLevelInstance(0x36E92B2751F260D6a4749d7CA58247E7f8198284);

        vm.stopBroadcast();
    }
}
