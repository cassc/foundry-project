// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";

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
    constructor(IForta _forta) {
        forta = _forta;
     }

    function handleTransaction(address user, bytes calldata msgData) external override {
        (address to, uint value, address from) = abi.decode(msgData[4:], (address, uint256, address));
        console.log("sweeping token from %s to %s amount %s", from, to, value);
        CryptoVault vault = CryptoVault(from);
        if (to == vault.sweptTokensRecipient()) {
            forta.raiseAlert(user);
        }
    }
}

contract DoubleEntryPointScript is Script {
    function setUp() public{
        vm.createSelectFork("sepolia");
    }

    function run() external{
        // address detAddress = 0x79da080684B9Bdc99B2385a77A289C3B78752Acd;
        // DoubleEntryPoint det = DoubleEntryPoint(detAddress); // underlying
        // CryptoVault vault = det.cryptoVault();
        // IForta forta = det.forta();

        // console.log("recipient: %s", vault.sweptTokensRecipient());

        // MyBot myBot = new MyBot(forta);
        // forta.setDetectionBot(address(myBot));
        vm.startBroadcast();
        address naut = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
        // naut.submitLevelInstance(payable(0x79da080684B9Bdc99B2385a77A289C3B78752Acd));
        naut.call(abi.encodeWithSignature("submitLevelInstance(address)", 0x79da080684B9Bdc99B2385a77A289C3B78752Acd));

        vm.stopBroadcast();
    }
}
