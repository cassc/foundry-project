// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface CryptoVault{
}

contract Attacker{

}

contract AttackerTest is Test {
    function setUp() public{
        vm.createSelectFork("sepolia" );
    }
    function test_doubleentrypoint() public{

    }
}
