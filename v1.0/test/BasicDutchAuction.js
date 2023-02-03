const { expect } = require ("chai");
const { ethers } = require  ("hardhat");
const { loadFixture } = require ("@nomicfoundation/hardhat-network-helpers");
const { smockit} = require("@eth-optimism/smock");

describe("BasicDutchAuction", function() {

    async function deployDutchAuctionFicture() {
        let myERC;
        const BasicDutchAuction = await ethers.getContractFactory("BasicDutchAuction");
        myERC = await BasicDutchAuction.deploy();
        const MyMockContract = await smockit(myERC);
        const Token = await ethers.getContractFactory("BasicDutchAuction");
        const mockedMintAmount = 30;
        MyMockContract.smocked.mintUpTo.will.return.with(mockedMintAmount);
        const myOtherContract = await Token.deploy(MyMockContract.address);
        
        const [owner, addr1, addr2] = await ethers.getSigners();

        const hardhatToken  = await Token.deploy(10, "nft", myOtherContract, 10, 10);

        await hardhatToken.transfer(addr1.address, 50);

        expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);
        
        return {hardhatToken, owner, addr1, addr2}; 
    }
    
    describe("bid", function() {
        it("bid failed", async function () {
            const {hardhatToken, owner, add1, addr2} = await loadFixture(deployDutchAuctionFicture);

            await hardhatToken.bid(0);
            expect(await hardhatToken.endAuction());

        });
    });
})