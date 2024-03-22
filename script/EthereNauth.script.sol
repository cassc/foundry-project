// SPDX-License-Identifier: MIT
// forge script script/EthereNauth.script.sol --private-key $PKEY --broadcast --rpc-url https://rpc.sepolia.org  -vvvv  --chain-id 11155111 --watch
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
        naut.call(abi.encodeWithSignature("createLevelInstance(address)", level));
    }

    function run() external{
        vm.startBroadcast();

        // createLevelInstance(0x653239b3b3E67BC0ec1Df7835DA2d38761FfD882);
        submitLevelInstance(0xd38112133E2162c7E87204a7D0C8cC535d7c4143);

        vm.stopBroadcast();
    }
}
