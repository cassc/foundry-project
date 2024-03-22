// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract T{
    constructor(){}
}

contract TransactionTest is Test {
    function setUp() public{
        vm.createSelectFork("mainnet", 19482241);
    }
    function test_tx() public{
        address sender = 0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B;
        vm.startPrank(sender);
        T t = new T();
        console.log("address: %s", address(t));
        //
    }
}
