// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFTDutchAuction is ERC721, Ownable {

    uint public startingPrice;
    uint public endingPrice;
    uint public duration;

    mapping (uint => uint) tokenIdToPrice;
    mapping (uint => uint) tokenIdToAuctionEnd;

    event AuctionCreated(uint indexed tokenId, uint startingPrice, uint endingPrice, uint duration);
    event AuctionSuccessful(uint indexed tokenId, uint totalPrice, address winner);
    event AuctionCancelled(uint indexed tokenId);

    constructor(string memory _name, string memory _symbol, uint _startingPrice, uint _endingPrice, uint _duration) ERC721(_name, _symbol) {
        startingPrice = _startingPrice;
        endingPrice = _endingPrice;
        duration = _duration;
    }

    function createAuction(uint _tokenId) public onlyOwner {
        require(_exists(_tokenId), "NFTDutchAuction: Token does not exist");
        require(tokenIdToAuctionEnd[_tokenId] == 0, "NFTDutchAuction: Token is already on auction");
        tokenIdToAuctionEnd[_tokenId] = block.timestamp + duration;
        tokenIdToPrice[_tokenId] = startingPrice;
        emit AuctionCreated(_tokenId, startingPrice, endingPrice, duration);
    }

    function bid(uint _tokenId) public payable {
        require(tokenIdToAuctionEnd[_tokenId] > 0, "NFTDutchAuction: Token is not on auction");
        require(block.timestamp < tokenIdToAuctionEnd[_tokenId], "NFTDutchAuction: Auction has already ended");
        require(msg.value >= currentPrice(_tokenId), "NFTDutchAuction: Bid too low");
        address tokenOwner = ownerOf(_tokenId);
        uint salePrice = tokenIdToPrice[_tokenId];
        tokenIdToAuctionEnd[_tokenId] = 0;
        tokenIdToPrice[_tokenId] = 0;
        _transfer(tokenOwner, msg.sender, _tokenId);
        if (msg.value > salePrice) {
            payable(tokenOwner).transfer(salePrice);
            payable(msg.sender).transfer(msg.value - salePrice);
        } else {
            payable(tokenOwner).transfer(msg.value);
        }
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
            uint priceIncrement = priceRange / duration;
            return startingPrice - (timeLeft * priceIncrement);
        }
    }

}
