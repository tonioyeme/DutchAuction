const NFTDutchAuction_ERC20Bids = artifacts.require('NFTDutchAuction_ERC20Bids');
const MockERC20 = artifacts.require('MockERC20');
const { expectRevert, time } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract('NFTDutchAuction_ERC20Bids', (accounts) => {
  const [owner, bidder] = accounts;
  const name = 'TestNFT';
  const symbol = 'TNFT';
  const reservePrice = 100;
  const numBlocksAuctionOpen = 10;
  const offerPriceDecrement = 5;
  let nft;
  let erc20;
  let tokenId;

  beforeEach(async () => {
    erc20 = await MockERC20.new();
    nft = await NFTDutchAuction_ERC20Bids.new(
      name,
      symbol,
      erc20.address,
      owner,
      1,
      reservePrice,
      numBlocksAuctionOpen,
      offerPriceDecrement
    );
    tokenId = 1;
    await nft.createAuction(tokenId, { from: owner });
  });

  describe('createAuction', () => {
    it('should create an auction for the given token by the owner', async () => {
      const auctionEnd = await nft.tokenIdToAuctionEnd(tokenId);
      const price = await nft.tokenIdToPrice(tokenId);
      expect(auctionEnd.toNumber()).to.be.closeTo(
        (await time.latest()).add(time.duration.days(numBlocksAuctionOpen)).toNumber(),
        2
      );
      expect(price.toNumber()).to.equal(reservePrice);
      expectEvent(await nft.createAuction(tokenId, { from: owner }), 'AuctionCreated', {
        tokenId: tokenId,
        startingPrice: reservePrice,
        endingPrice: reservePrice - offerPriceDecrement * numBlocksAuctionOpen,
        duration: numBlocksAuctionOpen,
      });
    });

    it('should throw an error if the token does not exist', async () => {
      const nonExistentTokenId = 2;
      await expectRevert(
        nft.createAuction(nonExistentTokenId, { from: owner }),
        'NFTDutchAuction: Token does not exist'
      );
    });

    it('should throw an error if the token is already on auction', async () => {
      await expectRevert(
        nft.createAuction(tokenId, { from: owner }),
        'NFTDutchAuction: Token is already on auction'
      );
    });
  });

  describe('bid', () => {
    const bidAmount = 120;

    beforeEach(async () => {
      await erc20.transfer(bidder, bidAmount);
      await erc20.approve(nft.address, bidAmount, { from: bidder });
    });

    it('should allow a bidder to bid on an ongoing auction with an amount equal to the current price', async () => {
      const currentPrice = await nft.currentPrice(tokenId);
      await expectEvent(await nft.bid(tokenId, currentPrice, { from: bidder }), 'AuctionSuccessful', {
        tokenId: tokenId,
        totalPrice: currentPrice,
        winner: bidder,
      });
    });

    // Test that a bidder can bid on an ongoing auction with an amount higher than the current price
it('should allow a bidder to bid on an ongoing auction with an amount higher than the current price', async () => {
    // Get the current price of the token
    const currentPrice = await nft.currentPrice(tokenId);

    // Bid on the token with an amount higher than the current price
    const bidAmount = currentPrice + 100;
    await nft.bid(tokenId, bidAmount, { from: bidder });

    // Check that the bid was successful
    const newOwner = await nft.ownerOf(tokenId);
    assert.equal(newOwner, bidder, "Bidder should be the new owner of the token");

    // Check that the bidder's balance was reduced by the bid amount
    const bidderBalanceAfter = await erc20.balanceOf(bidder);
    const expectedBidderBalance = bidderBalanceBefore - bidAmount;
    assert.equal(bidderBalanceAfter.toString(), expectedBidderBalance.toString(), "Bidder's balance was not reduced by the bid amount");

    // Check that the seller received the bid amount
    const sellerBalanceAfter = await erc20.balanceOf(seller);
    const expectedSellerBalance = sellerBalanceBefore + currentPrice;
    assert.equal(sellerBalanceAfter.toString(), expectedSellerBalance.toString(), "Seller did not receive the bid amount");
});

// Test that a bidder cannot bid on an ongoing auction with an amount lower than the current price
it('should not allow a bidder to bid on an ongoing auction with an amount lower than the current price', async () => {
    // Get the current price of the token
    const currentPrice = await nft.currentPrice(tokenId);

    // Bid on the token with an amount lower than the current price
    const bidAmount = currentPrice - 100;
    await expectRevert(nft.bid(tokenId, bidAmount, { from: bidder }), "NFTDutchAuction: Bid too low");

    // Check that the bid was not successful
    const currentOwner = await nft.ownerOf(tokenId);
    assert.equal(currentOwner, seller, "Seller should still be the owner of the token");

    // Check that the bidder's balance was not reduced
    const bidderBalanceAfter = await erc20.balanceOf(bidder);
    assert.equal(bidderBalanceAfter.toString(), bidderBalanceBefore.toString(), "Bidder's balance should not have been reduced");

    // Check that the seller did not receive any funds
    const sellerBalanceAfter = await erc20.balanceOf(seller);
    assert.equal(sellerBalanceAfter.toString(), sellerBalanceBefore.toString(), "Seller should not have received any funds");
});

// Test that a bidder cannot bid on an auction that has ended
it('should not allow a bidder to bid on an auction that has ended', async () => {
    // Fast-forward time to the end of the auction
    await time.increase(duration);

    // Bid on the token with an amount higher than the current price
    const bidAmount = startingPrice;
    await expectRevert(nft.bid(tokenId, bidAmount, { from: bidder }), "NFTDutchAuction: Auction has already ended");

    // Check that the bid was not successful
    const currentOwner = await nft.ownerOf(tokenId);
    assert.equal(currentOwner, seller, "Seller should still be the owner of the token");

    // Check that the bidder's balance was not reduced
    const bidderBalanceAfter = await erc20.balanceOf(bidder);
    assert.equal(bidderBalanceAfter.toString(), bidderBalanceBefore.toString(), "Bidder's balance should not be reduced after bidding");

    // Check that the owner's balance increased by the bid amount
const ownerBalanceAfter = await erc20.balanceOf(owner);
assert.equal(ownerBalanceAfter.sub(ownerBalanceBefore).toString(), bidAmount.toString(), "Owner's balance should increase by the bid amount");

// Check that the token ownership has been transferred to the bidder
const tokenOwner = await nft.ownerOf(tokenId);
assert.equal(tokenOwner, bidder, "Token ownership should be transferred to the bidder");

// Check that the auction has ended
const auctionEnd = await nft.tokenIdToAuctionEnd(tokenId);
assert.equal(auctionEnd.toString(), '0', 'Auction end time should be set to 0 after successful bid');

// Check that the token price has been reset to 0
const tokenPrice = await nft.tokenIdToPrice(tokenId);
assert.equal(tokenPrice.toString(), '0', 'Token price should be set to 0 after successful bid');

// Check that the AuctionSuccessful event was emitted with the correct parameters
const events = await nft.getPastEvents('AuctionSuccessful', { fromBlock: 0, toBlock: 'latest' });
assert.equal(events.length, 1, 'AuctionSuccessful event should be emitted once');
assert.equal(events[0].returnValues.tokenId, tokenId.toString(), 'AuctionSuccessful event should have the correct tokenId');
assert.equal(events[0].returnValues.totalPrice, currentPrice.toString(), 'AuctionSuccessful event should have the correct total price');
assert.equal(events[0].returnValues.winner, bidder, 'AuctionSuccessful event should have the correct winner');
});

it('should allow the owner to cancel an ongoing auction', async () => {
const tokenId = 1;
const owner = accounts[0];
const bidder = accounts[1];
const bidAmount = web3.utils.toWei('2', 'ether');

// Transfer ownership of the token to the contract
await nft.transferFrom(owner, nft.address, tokenId);

// Set up the auction
await nft.createAuction(tokenId);

// Cancel the auction
await nft.cancelAuction(tokenId);

// Check that the auction has been cancelled
const auctionEnd = await nft.tokenIdToAuctionEnd(tokenId);
assert.equal(auctionEnd.toString(), '0', 'Auction end time should be set to 0 after cancellation');

// Check that the token price has been reset to 0
const tokenPrice = await nft.tokenIdToPrice(tokenId);
assert.equal(tokenPrice.toString(), '0', 'Token price should be set to 0 after cancellation');

// Check that the token ownership has been returned to the owner
const tokenOwner = await nft.ownerOf(tokenId);
assert.equal(tokenOwner, owner, 'Token ownership should be returned to the owner');

// Check that the AuctionCancelled event was emitted with the correct parameters
const events = await nft.getPastEvents('AuctionCancelled', { fromBlock: 0, toBlock: 'latest' });
assert.equal(events.length, 1, 'AuctionCancelled event should be emitted once');
assert.equal(events[0].returnValues.tokenId, tokenId.toString(), 'AuctionCancelled event should have the correct tokenId');


});
});

})

