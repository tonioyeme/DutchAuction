pragma solidity =0.8.0;

import "ds-test/test.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../contracts/UniswapV2Factory.sol";
import "../contracts/UniswapV2Pair.sol";

contract UniswapV2FactoryTest is DSTest {
    UniswapV2Factory factory;
    address feeToSetter;

    function setUp() public {
        feeToSetter = address(this);
        factory = new UniswapV2Factory(feeToSetter);
    }

    function test_feeToSetter() public {
        assertEq(factory.feeToSetter(), feeToSetter);
    }

    function test_createPair() public {
        address tokenA = address(0x1);
        address tokenB = address(0x2);
        address pair = factory.createPair(tokenA, tokenB);
        assertEq(factory.getPair(tokenA, tokenB), pair);
        assertEq(factory.getPair(tokenB, tokenA), pair);
        assertEq(factory.allPairs(0), pair);
    }

    function testFail_createPair_identicalAddresses() public {
        address tokenA = address(0x1);
        factory.createPair(tokenA, tokenA);
    }

    function testFail_createPair_zeroAddress() public {
        address tokenA = address(0x0);
        address tokenB = address(0x2);
        factory.createPair(tokenA, tokenB);
    }

    function testFail_createPair_pairExists() public {
        address tokenA = address(0x1);
        address tokenB = address(0x2);
        factory.createPair(tokenA, tokenB);
        factory.createPair(tokenA, tokenB);
    }

    function test_setFeeTo() public {
        address newFeeTo = address(0x3);
        factory.setFeeTo(newFeeTo);
        assertEq(factory.feeTo(), newFeeTo);
    }

    function testFail_setFeeTo_forbidden() public {
        UniswapV2Factory otherFactory = new UniswapV2Factory(address(0x0));
        otherFactory.setFeeTo(address(this));
    }

    function test_setFeeToSetter() public {
        address newFeeToSetter = address(0x4);
        factory.setFeeToSetter(newFeeToSetter);
        assertEq(factory.feeToSetter(), newFeeToSetter);
    }

    function testFail_setFeeToSetter_forbidden() public {
        UniswapV2Factory otherFactory = new UniswapV2Factory(address(0x0));
        otherFactory.setFeeToSetter(address(this));
    }
}
