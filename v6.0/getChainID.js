const Web3 = require('web3');

const web3 = new Web3('https://eth-mainnet.g.alchemy.com/v2/LPZ0asSARjCxyWs_ogU8d5TSpMxoqvC3');

async function getChainID() {
  try {
    const chainId = await web3.eth.getChainId();
    console.log('Chain ID:', chainId);
  } catch (error) {
    console.error('Error getting Chain ID:', error);
  }
}

getChainID();

