const Web3 = require('web3');

const web3 = new Web3('http://localhost:7545');

const fs = require('fs');

const BasicDutchAuctionABIJSON = fs.readFileSync('/Users/toni/info7500/DutchAuction/v6.0/contracts/BasicDutchAuction_sol_BasicDutchAuction.abi', 'utf8');
const BasicDutchAuctionABI = JSON.parse(BasicDutchAuctionABIJSON);
const BasicDutchAuctionBytecode = fs.readFileSync('/Users/toni/info7500/DutchAuction/v6.0/contracts/BasicDutchAuction_sol_BasicDutchAuction.bin', 'utf8');

async function deploy() {
    const accounts = await web3.eth.getAccounts();
    const seller = accounts[0];
    const offerPriceDecrement = 100; 
    const nft = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
    const nftId = 1;
    const numBlocksAuctionOpen = 100;
    const reservePrice = 50;

    const BasicDutchAuctionContract = new web3.eth.Contract(BasicDutchAuctionABI);
    const deployTx = BasicDutchAuctionContract.deploy({
      data: BasicDutchAuctionBytecode,
      arguments: [
        offerPriceDecrement,
        nft,
        nftId,
        numBlocksAuctionOpen,
        reservePrice,
      ],
    });
  
    const gas = await deployTx.estimateGas();
    const gasPrice = await web3.eth.getGasPrice();
  
    console.log('Deploying BasicDutchAuction contract...');
    const contractInstance = await deployTx.send({
      from: seller,
      gas: gas,
      gasPrice: gasPrice,
    });
  
      console.log(`BasicDutchAuction contract deployed at address: ${contractInstance.options.address}`);
    
  }
  

deploy();
