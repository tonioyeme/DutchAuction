/*
1.The seller instantiates a DutchAuction contract to manage the auction of a single, physical item at a single auction event. The contract is initialized with the following parameters: 
  a.reservePrice: the minimum amount of wei that the seller is willing to accept for the item 
  b.numBlocksAuctionOpen: the number of blockchain blocks that the auction is open for
  c.offerPriceDecrement: the amount of wei that the auction price should decrease by during each subsequent block. 
2.The seller is the owner of the contract. 
3.The auction begins at the block in which the contract is created. 
4.The initial price of the item is derived from reservePrice, numBlocksAuctionOpen, and  offerPriceDecrement: initialPrice = reservePrice + numBlocksAuctionOpen*offerPriceDecrement 
5.A bid can be submitted by any Ethereum externally-owned account. 
6.The first bid processed by the contract that sends wei greater than or equal to the current price is the winner. The wei should be transferred immediately to the seller and the contract should not accept  any more bids. All bids besides the winning bid should be refunded immediately. 
*/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    function transferFrom(address _from, address _to,uint _nftId) external;
}

// This is the main building block for smart contracts.
contract BasicDutchAuction {
    IERC721 public immutable nft;
    uint public immutable nftId;//id of the nft

    address payable public immutable seller;
    address public winner;
    uint public immutable startPrice;
    uint public immutable startAt;
    uint public immutable endAt;
    uint public immutable offerPriceDecrement;
    uint public immutable numBlocksAuctionOpen;
    uint public immutable reservePrice;
    bool public endAuction;

    constructor(
        uint _offerPriceDecrement,
        address _nft,
        uint _nftId,
        uint _numBlocksAuctionOpen,
        uint _reservePrice
    ) {
        seller = payable(msg.sender);
        offerPriceDecrement = _offerPriceDecrement;
        numBlocksAuctionOpen = _numBlocksAuctionOpen;
        reservePrice = _reservePrice;
        //startPrice = reservePrice + numBlocksAuctionOpen * offerPriceDecrement;
        startPrice = 100 ether;
        startAt = block.timestamp;
        endAt = startAt + (numBlocksAuctionOpen * 100 seconds); // assuming each block is mined in 15 seconds

        
        endAuction = false;

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint) {
        return startPrice - offerPriceDecrement * numBlocksAuctionOpen;

    }

    function bid() external payable {
        require(block.timestamp < endAt,  "auction ended" );

        uint price = getPrice();
        require(msg.value >= price, "not enough" ); //the amount sent >= price
        winner = msg.sender;

        nft.transferFrom(seller, winner, nftId); //transfer the ownership of the nft
        //refund if the buyer(winner) sent too much
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    

    }




}