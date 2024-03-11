// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";

interface ClearingHouse {
    function treasuryAddress() external view returns (address);
}

contract PolygonContractTest is Test {
    function setUp() public {
        vm.createSelectFork("polygon");
    }

    function test_polygon() public {
        address addr = ClearingHouse(0x182520033847B9039E47746E454Dc0CF0a4e2B1C).treasuryAddress();
        console.log("treasuryAddress: ", addr);
    }


}
