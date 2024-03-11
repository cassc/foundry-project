// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract Minimum{
    address public addr;
    constructor(){
        // init code
        // prepare CODECOPY
        // PUSH1 0x0a // size of code, 10 bytes
        // PUSH1 0x0c // offset of code, 12 bytes
        // PUSH1 0x00 // offset in memory
        // CODECOPY(0x39)  consumes 3 stacks
        // return the complete runtime opcode
        // PUSH1 0x0a // size of runtime code 10 bytes
        // PUSH1 0x00 // offset in memory, 0
        // RETURN(0xf3) consumes 2 stacks
        // Runtime code
        // prepare MSTORE
        // PUSH1 0x2a // value: 42
        // PUSH1 0x80 // offset in memory
        // MSTORE(0x52) consumes 2 stacks
        // prepare RETURN
        // PUSH1 0x20 // size of return data
        // PUSH1 0x80 // offset in memory, should be same as MSTORE offset above
        // RETURN consumes 2 stacks

        bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3";
        uint saltN = 0;
        bytes32 salt = keccak256(abi.encodePacked(saltN, msg.sender));
        address _contractAddress;
        assembly {
            // value offset code salt
        _contractAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
                }

        require(_contractAddress != address(0), "Failed to deploy contract");
        addr = _contractAddress;
    }

}

contract MinimalTest is Test {
    function test_minimal() public{
        Minimum m = new Minimum();
        address addr = m.addr();
        (bool success, bytes memory data) = addr.call(abi.encodeWithSignature("test()"));
        require(success, "Failed to call contract");

        uint256 result = abi.decode(data, (uint256));

        console.log("result: ", result);

        require(result == 42, "Invalid result");
    }
}
