pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "./../libraries/SafeMath.sol";
import "./../interfaces/IUniswapV2Pair.sol";
import "./../src/contracts/UniswapV2ERC20.sol";

contract UniswapV2ERC20Test is DSTest {
    UniswapV2ERC20 erc20;

    function setUp() public {
        erc20 = new UniswapV2ERC20();
    }

    function test_name() public {
        assertEq(erc20.name(), "Uniswap V2");
    }

    function test_symbol() public {
        assertEq(erc20.symbol(), "UNI-V2");
    }

    function test_decimals() public {
        assertEq(erc20.decimals(), 18);
    }

    function test_initial_totalSupply() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_initial_balanceOf() public {
        assertEq(erc20.balanceOf(address(this)), 0);
    }

    function test_initial_allowance() public {
        assertEq(erc20.allowance(address(this), address(0x1)), 0);
    }

    function test_approve() public {
        assertTrue(erc20.approve(address(0x1), 100));
        assertEq(erc20.allowance(address(this), address(0x1)), 100);
    }

    function test_transfer() public {
        uint initialSupply = erc20.totalSupply();
        erc20._mint(address(this), 1000);
        assertTrue(erc20.transfer(address(0x1), 500));
        assertEq(erc20.balanceOf(address(this)), 500);
        assertEq(erc20.balanceOf(address(0x1)), 500);
        assertEq(erc20.totalSupply(), initialSupply + 1000);
    }

    function test_transferFrom() public {
        erc20._mint(address(this), 1000);
        erc20.approve(address(0x1), 500);
        assertTrue(erc20.transferFrom(address(this), address(0x1), 300));
        assertEq(erc20.allowance(address(this), address(0x1)), 200);
        assertEq(erc20.balanceOf(address(this)), 700);
        assertEq(erc20.balanceOf(address(0x1)), 300);
    }

    function test_MINIMUM_LIQUIDITY() public {
    assertEq(erc20.MINIMUM_LIQUIDITY(), 1000);
}

function test_burn() public {
    erc20._mint(address(this), 1000);
    erc20._mint(address(0x1), 500);
    (uint amount0, uint amount1) = erc20.burn(address(0x1));
    assertEq(amount0, 1000);
    assertEq(amount1, 500);
    assertEq(erc20.totalSupply(), 0);
    assertEq(erc20.balanceOf(address(this)), 0);
    assertEq(erc20.balanceOf(address(0x1)), 0);
}

function test_factory() public {
    // Set _factory in your contract to a non-zero address before testing
    assertEq(erc20.factory(), address(0x0)); // Replace 0x0 with your factory address
}

function test_getReserves() public {
    (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = erc20.getReserves();
    assertEq(reserve0, 0);
    assertEq(reserve1, 0);
    assertEq(blockTimestampLast, 0);
}

function test_initialize() public {
    erc20.initialize(address(0x1), address(0x2));
    assertEq(erc20.token0(), address(0x1));
    assertEq(erc20.token1(), address(0x2));
}

function test_kLast() public {
    // Set _kLast in your contract to a non-zero value before testing
    assertEq(erc20.kLast(), 0); // Replace 0 with your kLast value
}

function test_mint() public {
    uint liquidity = erc20.mint(address(this));
    assertEq(liquidity, erc20.totalSupply());
    assertEq(erc20.balanceOf(address(this)), liquidity);
}

function test_priceCumulativeLast() public {
    // Set _price0CumulativeLast and _price1CumulativeLast in your contract to non-zero values before testing
    assertEq(erc20.price0CumulativeLast(), 0); // Replace 0 with your price0CumulativeLast value
    assertEq(erc20.price1CumulativeLast(), 0); // Replace 0 with your price1CumulativeLast value
}

function test_skim() public {
    erc20._mint(address(this), 1000);
    erc20.skim(address(0x1));
    assertEq(erc20.balanceOf(address(0x1)), 1000);
    assertEq(erc20.balanceOf(address(this)), 0);
}

function test_swap() public {
    erc20._mint(address(this), 1000);
    erc20.swap(500, 0, address(0x1), "");
    assertEq(erc20.balanceOf(address(this)), 500);
    assertEq(erc20.balanceOf(address(0x1)), 500);
}

function test_sync() public {
    erc20.initialize(address(0x1), address(0x2));
    erc20._mint(address(0x1), 1000);
    erc20._mint(address(0x2), 2000);
    erc20.sync();
    (uint112 reserve0, uint112 reserve1, ) = erc20.getReserves();
    assertEq(reserve0, 1000    assertEq(reserve1, 2000);
}

function test_token0() public {
    erc20.initialize(address(0x1), address(0x2));
    assertEq(erc20.token0(), address(0x1));
}

function test_token1() public {
    erc20.initialize(address(0x1), address(0x2));
    assertEq(erc20.token1(), address(0x2));
}


}
