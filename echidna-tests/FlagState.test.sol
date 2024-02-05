// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./FlagStore.sol";


contract TestFlagStore  {
    FlagStore flagStore;
    uint initBalance;

    constructor() payable{
        initBalance = msg.value / 2;
        flagStore = new FlagStore{value: initBalance}();
    }
    
    function echidna_check_balance() public view returns (bool) {
        return address(flagStore).balance >= initBalance;
    }
}
