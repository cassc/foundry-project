// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";

interface DelegateERC20 {
  function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
}

interface CryptoVault {
    function sweepToken(address token) external;
    function sweptTokensRecipient() external view returns (address) ;
    function underlying() external view returns (DoubleEntryPoint) ;

}

interface LegacyToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function delegate() external view returns (DelegateERC20);
}

interface DoubleEntryPoint {
    function player() external view returns (address);
    function cryptoVault() external view returns (CryptoVault);
    function forta() external view returns (IForta);
    function delegatedFrom() external view returns (LegacyToken);
    function balanceOf(address account) external view returns (uint256);
}

contract MyBot is IDetectionBot {
    IForta forta;
    address vault;
    constructor(IForta _forta, address _vault) {
        forta = _forta;
        vault = _vault;
     }

    function handleTransaction(address user, bytes calldata msgData) external override {
        (address to, uint value, address from) = abi.decode(msgData[4:], (address, uint256, address));
        console.log("sweeping token from %s to %s amount %s", from, to, value);

        // prevent removing token from the vault
        if (from == vault) {
            forta.raiseAlert(user);
        }
    }
}

contract AttackerTest is Test {
    function setUp() public{
        vm.createSelectFork("sepolia", 5479616);
    }

    function transfer(address _to, uint amount) public returns (bool){
        // msg.sender is vault
        return true;
    }

    function balanceOf(address account) public view returns (uint256){
        return 100;
    }


    function test_doubleentrypoint() public{
        vm.startPrank(0x8AC4E3906688EfE71818531a9e439A7ABFDA0154);

        address detAddress = 0x79da080684B9Bdc99B2385a77A289C3B78752Acd;
        DoubleEntryPoint det = DoubleEntryPoint(detAddress); // underlying
        CryptoVault vault = det.cryptoVault();
        IForta forta = det.forta();

        console.log("recipient: %s", vault.sweptTokensRecipient());

        MyBot myBot = new MyBot(forta, address(vault));
        forta.setDetectionBot(address(myBot));

        require(address(det) == detAddress, "Expecting same address");

        LegacyToken legacyToken = det.delegatedFrom();

        vm.label(address(detAddress), "DET");
        vm.label(address(vault), "vault");
        vm.label(address(forta), "forta");
        vm.label(address(legacyToken), "legacyToken");
        vm.label(address(this), "attacker");

        console.log("DET balance: %s", det.balanceOf(address(vault)));
        console.log("Legacy balance: %s", legacyToken.balanceOf(address(vault)));

        vm.expectRevert();
        vault.sweepToken(address(legacyToken));

        // require(0 == det.balanceOf(address(vault)), "Underlying balance should 0");

    }
}
