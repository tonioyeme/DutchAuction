const { expect } = require("chai");
const { ethers } = require("hardhat");



describe("NFTDutchAuction", function () {
  let nftAuction;

  beforeEach(async function () {
    const NFTAuction = await ethers.getContractFactory("NFTDutchAuction");
    nftAuction = await NFTAuction.deploy("MyNFT", "MNFT", 1000, 10, 3600);
    await nftAuction.deployed();
  });

  it("Should create an auction for a token", async function () {
    await nftAuction.createAuction(1);
    expect(await nftAuction.tokenIdToAuctionEnd(1)).to.be.gt(0);
  });

  it("Should not allow non-owners to create an auction", async function () {
    await expect(nftAuction.connect(signers[1]).createAuction(1)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("Should not allow bidding on an auction that does not exist", async function () {
    await expect(nftAuction.bid(1)).to.be.revertedWith("NFTDutchAuction: Token is not on auction");
  });

  it("Should not allow bidding after an auction has ended", async function () {
    await nftAuction.createAuction(1);
    await ethers.provider.send("evm_increaseTime", [3601]); // increase time by 1 hour
    await expect(nftAuction.bid(1)).to.be.revertedWith("NFTDutchAuction: Auction has already ended");
  });

  it("Should transfer ownership and funds to winner after successful auction", async function () {
    const [owner, bidder] = await ethers.getSigners();
    const tokenId = 1;
    await nftAuction.createAuction(tokenId);
    const currentPrice = await nftAuction.currentPrice(tokenId);
    await nftAuction.connect(bidder).bid(tokenId, { value: currentPrice });
    expect(await nftAuction.ownerOf(tokenId)).to.equal(bidder.address);
    expect(await ethers.provider.getBalance(nftAuction.address)).to.equal(currentPrice);
  });
});
