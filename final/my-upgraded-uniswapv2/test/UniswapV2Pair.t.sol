pragma solidity =0.8.0;

import 'remix_tests.sol';
import 'remix_accounts.sol';
import '../contracts/UniswapV2Pair.sol';
import '../contracts/interfaces/IERC20.sol';

contract UniswapV2PairTest {
    using Assert for uint;

    UniswapV2Pair public pair;
    IERC20 token0;
    IERC20 token1;
    address factory;
    address deployer;
    address alice = TestsAccounts.getAccount(0);
    address bob = TestsAccounts.getAccount(1);

    function beforeEach() public {
        deployer = msg.sender;
        factory = deployer; // For testing purposes, the deployer will also act as the factory
        token0 = new IERC20("Token0", "T0");
        token1 = new IERC20("Token1", "T1");
        pair = new UniswapV2Pair();
        pair.initialize(address(token0), address(token1));
    }

    /// @notice Test initial state of the UniswapV2Pair contract
    function testInitialState() public {
        Assert.equal(pair.factory(), factory, "Incorrect factory address");
        Assert.equal(pair.token0(), address(token0), "Incorrect token0 address");
        Assert.equal(pair.token1(), address(token1), "Incorrect token1 address");
    }

    /// @notice Test minting of liquidity tokens
    function testMint() public {
        // Transfer tokens to alice and bob
        token0.transfer(alice, 1000 * 10**18);
        token1.transfer(alice, 1000 * 10**18);

        // Approve pair contract to spend alice's tokens
        token0.approve(address(pair), 1000 * 10**18);
        token1.approve(address(pair), 1000 * 10**18);

        // Mint liquidity tokens
        pair.mint(alice);

        // Verify the balances of token0 and token1 in the pair contract
        uint balance0 = token0.balanceOf(address(pair));
        uint balance1 = token1.balanceOf(address(pair));

        Assert.equal(balance0, 1000 * 10**18, "Incorrect token0 balance in pair");
        Assert.equal(balance1, 1000 * 10**18, "Incorrect token1 balance in pair");
    }


    describe('burn', function () {
        it('should burn liquidity and send the corresponding tokens to the specified address', async function () {
            // Add liquidity
            await addLiquidity(1000, 1000);

            // Call burn function and check balances
            await uniswapV2.burn(addr1.address);
            expect(await token0.balanceOf(addr1.address)).to.be.above(0);
            expect(await token1.balanceOf(addr1.address)).to.be.above(0);
        });

        it('should revert if there is insufficient liquidity to burn', async function () {
            await expect(uniswapV2.burn(addr1.address)).to.be.revertedWith('UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        });
    });

    describe('swap', function () {
        it('should swap tokens correctly', async function () {
            // Add liquidity
            await addLiquidity(1000, 1000);

            // Call swap function and check balances
            await uniswapV2.swap(10, 0, addr1.address, []);
            expect(await token0.balanceOf(addr1.address)).to.equal(10);
            expect(await token1.balanceOf(addr1.address)).to.equal(0);
        });

        it('should revert if output amounts are insufficient', async function () {
            await expect(uniswapV2.swap(0, 0, addr1.address, [])).to.be.revertedWith('UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        });

        it('should revert if there is insufficient liquidity for the swap', async function () {
            await expect(uniswapV2.swap(1000, 1000, addr1.address, [])).to.be.revertedWith('UniswapV2: INSUFFICIENT_LIQUIDITY');
        });

        it('should revert if the `to` address is the same as either token', async function () {
            await expect(uniswapV2.swap(10, 0, token0.address, [])).to.be.revertedWith('UniswapV2: INVALID_TO');
            await expect(uniswapV2.swap(0, 10, token1.address, [])).to.be.revertedWith('UniswapV2: INVALID_TO');
});
});

describe('skim', function () {
    it('should force balances to match reserves', async function () {
        // Add liquidity
        await addLiquidity(1000, 1000);

        // Simulate a balance mismatch
        await token0.transfer(uniswapV2.address, 100);
        await token1.transfer(uniswapV2.address, 100);

        // Call skim function and check balances
        await uniswapV2.skim(addr1.address);
        expect(await token0.balanceOf(addr1.address)).to.equal(100);
        expect(await token1.balanceOf(addr1.address)).to.equal(100);
    });
});

describe('sync', function () {
    it('should force reserves to match balances', async function () {
        // Add liquidity
        await addLiquidity(1000, 1000);

        // Simulate a reserve mismatch
        await token0.transfer(uniswapV2.address, 100);
        await token1.transfer(uniswapV2.address, 100);

        // Call sync function
        await uniswapV2.sync();

        // Get updated reserves
        const reserves = await uniswapV2.getReserves();

        // Check if reserves match balances
        expect(reserves.reserve0).to.equal(await token0.balanceOf(uniswapV2.address));
        expect(reserves.reserve1).to.equal(await token1.balanceOf(uniswapV2.address));
    });
});

    
}
