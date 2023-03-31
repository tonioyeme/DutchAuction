import BasicDutchAuctionABI from 'dutch-auction-app/src/BasicDutchAuction.json';
import BasicDutchAuctionBytecode from './BasicDutchAuctionBytecode.txt';

import Web3 from 'web3';

const web3 = new Web3('https://eth-mainnet.g.alchemy.com/v2/LPZ0asSARjCxyWs_ogU8d5TSpMxoqvC3'); // my Ethereum node URL

const BasicDutchAuctionContract = new web3.eth.Contract(BasicDutchAuctionABI);

const path = require('path');
const fs = require('fs');
const solc = require('solc');

const contractPath = path.resolve(__dirname, 'contracts/BasicDutchAuction.sol');
const contractSource = fs.readFileSync(contractPath, 'utf8');

const input = {
    language: 'Solidity',
    sources: {
      'BasicDutchAuction.sol': {
        content: contractSource,
      },
    },
    settings: {
      outputSelection: {
        '*': {
          '*': ['abi', 'evm.bytecode'],
        },
      },
    },
  };
  const output = JSON.parse(solc.compile(JSON.stringify(input)));
  const abi = output.contracts['BasicDutchAuction.sol']['BasicDutchAuction'].abi;
  const bytecode = output.contracts['BasicDutchAuction.sol']['BasicDutchAuction'].evm.bytecode.object;
  
fs.writeFileSync(path.resolve(__dirname, 'dutch-auction-app/src/BasicDutchAuction.json'), JSON.stringify(abi));
fs.writeFileSync(path.resolve(__dirname, 'dutch-auction-app/src/BasicDutchAuctionBytecode.txt'), bytecode);
