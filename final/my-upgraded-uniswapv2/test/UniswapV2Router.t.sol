pragma solidity =0.8.0;

import "forge-std/Test.sol";
import "../src/contracts/UniswapV2Router02.sol";
import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IWETH.sol";

/// Extend the abstract contract to make it instantiable for testing purposes
abstract contract TestableUniswapV2Router02 is UniswapV2Router02 {
    constructor(address _factory, address _WETH) UniswapV2Router02(_factory, _WETH) {}

    // Implement the missing functions as empty functions
function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) public returns (uint amountA, uint amountB, uint liquidity) { }

function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) public payable returns (uint amountToken, uint amountETH, uint liquidity) { }

function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) public override returns (uint amountA, uint amountB) { }


function quote(
    uint amountA, 
    uint reserveA, 
    uint reserveB
    ) public pure virtual returns (uint amountB) {}

function getAmountOut(
    uint amountIn, 
    uint reserveIn, 
    uint reserveOut
    ) public pure virtual returns (uint amountOut){}
function getAmountIn(
    uint amountOut, 
    uint reserveIn, 
    uint reserveOut
    ) public pure virtual returns (uint amountIn){}
function getAmountsOut(
    uint amountIn, 
    address[] memory path
    ) public view virtual returns (uint[] memory amounts){}
function getAmountsIn(
    uint amountOut, 
    address[] memory path
    ) public view virtual returns (uint[] memory amounts){}



function swap(TestableUniswapV2Router02 router, uint[] memory amounts, address[] memory path, address to) internal {
    for (uint i; i < path.length - 1; i++) {
        (address input, address output) = (path[i], path[i + 1]);
        (address token0, address token1) = UniswapV2Library.sortTokens(input, output);
        uint amountOut = amounts[i + 1];
        (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
        address to = i < path.length - 2 ? UniswapV2Library.pairFor(router.factory(), output, path[i + 2]) : to;
        IUniswapV2Pair(UniswapV2Library.pairFor(router.factory(), input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
    }
}

function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) public returns (uint amountToken, uint amountETH) { }

function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) public returns (uint amountETH) { }

function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
) public returns (uint amountToken, uint amountETH) { }

function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
) public returns (uint amountETH) { }

function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
) public returns (uint amountA, uint amountB) { }


function swapTokensForExactTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) public override returns (uint[] memory amounts) { }


function swapETHForExactTokens(
    uint amountOut,
    address[] calldata path,
    address to,
    uint deadline
) public payable returns (uint[] memory amounts) { }

function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) public payable returns (uint[] memory amounts) { }

function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) public payable returns (uint[] memory amounts) { }

function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) public returns (uint[] memory amounts) { }

function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) public returns (uint[] memory amounts) { }


     function swapExactETHForTokens(
        uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
     ) public payable returns (
        uint[] memory amounts
     ) { }

    
}

contract UniswapV2Router02Test is Test {
    TestableUniswapV2Router02 router;
    IERC20 tokenA;
    IERC20 tokenB;
    IWETH WETH;

    // Replace with actual contract addresses
    address factory = address(0x1234567890123456789012345678901234567890);
    address WETHAddress = address(0x0987654321098765432109876543210987654321);

    function setUp() public {
        router = new TestableUniswapV2Router02(factory, WETHAddress);
        // Replace with actual ERC20 token instances
        tokenA = IERC20(/* tokenA contract address */ address(0x1111111111111111111111111111111111111111));
        tokenB = IERC20(/* tokenB contract address */ address(0x2222222222222222222222222222222222222222));
        WETH = IWETH(WETHAddress);
    }

   function test_receive() public {
    IERC20 WETHAsERC20 = IERC20(address(WETH));
    assertEq(WETHAsERC20.balanceOf(address(this)), 0);
    uint256 amount = 10 ether;
    WETH.deposit{value: amount}();
    assertEq(WETHAsERC20.balanceOf(address(this)), amount);
    WETH.transfer(address(router), amount);
    assertEq(WETHAsERC20.balanceOf(address(router)), amount);
}


    function test_quote() public {
        uint amountA = 500;
        uint reserveA = 1000;
        uint reserveB = 2000;
        uint amountB = router.quote(amountA, reserveA, reserveB);
        assertEq(amountB, 1000);
    }

    function test_getAmountOut() public {
        uint amountIn = 500;
        uint reserveIn = 1000;
        uint reserveOut = 2000;
        uint amountOut = router.getAmountOut(amountIn, reserveIn, reserveOut);
        assertEq(amountOut, 982);
    }

    function test_getAmountIn() public {
        uint amountOut = 500;
        uint reserveIn = 1000;
        uint reserveOut = 2000;
        uint amountIn = router.getAmountIn(amountOut, reserveIn, reserveOut);
        assertEq(amountIn, 517);
    }

    function test_getAmountsOut() public {
        uint amountIn = 500;
        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(WETH);
        path[2] = address(tokenB);

        uint[] memory amounts = router.getAmountsOut(amountIn, path);
        assertEq(amounts[0], amountIn);
        assert(amounts[1] > 0);
        assert(amounts[2] > 0);
    }

    function test_getAmountsIn() public {
        uint amountOut = 500;
        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(WETH);
        path[2] = address(tokenB);

        uint[] memory amounts = router.getAmountsIn(amountOut, path);
        assert(amounts[0] > 0);
        assert(amounts[1] > 0);
        assertEq(amounts[2], amountOut);
    }
}