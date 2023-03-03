// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";



contract NFTDutchAuction_ERC20Bids is ERC721, UUPSUpgradeable, Ownable {
uint public startingPrice;
uint public endingPrice;
uint public duration;
address public erc20TokenAddress;

mapping (uint => uint) tokenIdToPrice;
mapping (uint => uint) tokenIdToAuctionEnd;

event AuctionCreated(uint indexed tokenId, uint startingPrice, uint endingPrice, uint duration);
event AuctionSuccessful(uint indexed tokenId, uint totalPrice, address winner);
event AuctionCancelled(uint indexed tokenId);

function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}


constructor(
        string memory _name,
        string memory _symbol,
        address _erc20TokenAddress,
        address _erc721TokenAddress,
        uint256 _nftTokenId,
        uint256 _reservePrice,
        uint256 _numBlocksAuctionOpen,
        uint256 _offerPriceDecrement
    ) ERC721(_name, _symbol) {
        startingPrice = _reservePrice;
        endingPrice = _reservePrice - (_offerPriceDecrement * _numBlocksAuctionOpen);
        duration = _numBlocksAuctionOpen;
        erc20TokenAddress = _erc20TokenAddress;
        transferFrom(_erc721TokenAddress, msg.sender, _nftTokenId);
    }


function createAuction(uint _tokenId) public onlyOwner {
    require(_exists(_tokenId), "NFTDutchAuction: Token does not exist");
    require(tokenIdToAuctionEnd[_tokenId] == 0, "NFTDutchAuction: Token is already on auction");
    tokenIdToAuctionEnd[_tokenId] = block.timestamp + duration;
    tokenIdToPrice[_tokenId] = startingPrice;
    emit AuctionCreated(_tokenId, startingPrice, endingPrice, duration);
    require(tokenIdToAuctionEnd[_tokenId] == 0, "NFTDutchAuction: Token is already on auction");

}

function bid(uint _tokenId, uint256 _bidAmount) public {
    require(tokenIdToAuctionEnd[_tokenId] > 0, "NFTDutchAuction: Token is not on auction");
    require(block.timestamp < tokenIdToAuctionEnd[_tokenId], "NFTDutchAuction: Auction has already ended");
    require(_bidAmount >= currentPrice(_tokenId), "NFTDutchAuction: Bid too low");
    address tokenOwner = ownerOf(_tokenId);
    uint salePrice = tokenIdToPrice[_tokenId];
    tokenIdToAuctionEnd[_tokenId] = 0;
    tokenIdToPrice[_tokenId] = 0;
    _transfer(tokenOwner, msg.sender, _tokenId);
    IERC20(erc20TokenAddress).transferFrom(msg.sender, tokenOwner, salePrice);
    emit AuctionSuccessful(_tokenId, salePrice, msg.sender);
}

function cancelAuction(uint _tokenId) public onlyOwner {
    require(tokenIdToAuctionEnd[_tokenId] > 0, "NFTDutchAuction: Token is not on auction");
    tokenIdToAuctionEnd[_tokenId] = 0;
    tokenIdToPrice[_tokenId] = 0;
    emit AuctionCancelled(_tokenId);
}

function currentPrice(uint _tokenId) public view returns (uint) {
    require(tokenIdToAuctionEnd[_tokenId] > 0, "NFTDutchAuction: Token is not on auction");
    uint timeLeft = tokenIdToAuctionEnd[_tokenId] - block.timestamp;
    if (timeLeft >= duration) {
        return startingPrice;
    } else if (timeLeft == 0) {
    return endingPrice;
} else {
    uint priceRange = startingPrice - endingPrice;
    uint priceDecrement = priceRange / duration;
    uint currentPrice = startingPrice - (timeLeft * priceDecrement);
    if (currentPrice < endingPrice) {
        return endingPrice;
    } else {
        return currentPrice;
    }
}
}

}