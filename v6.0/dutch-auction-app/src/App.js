import React, { useState, useEffect } from 'react';
import BasicDutchAuctionABI from './BasicDutchAuction.json';
import BasicDutchAuctionBytecode from './BasicDutchAuctionBytecode.txt';
import Web3 from 'web3';

const web3 = new Web3('http://localhost:7545'); // my Ethereum node URL, localhost for testing

function App() {
  //connect to account and basic info
  const [account, setAccount] = useState('');
  const [balance, setBalance] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  async function connectAccount() {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
        setIsConnected(true);
        updateBalance(accounts[0]);
      } catch (error) {
        setErrorMsg('Error connecting to MetaMask.');
      }
    } else {
      setErrorMsg('MetaMask is not installed.');
    }
  }
  
  function disconnectAccount() {
    setAccount('');
    setBalance('');
    setIsConnected(false);
  }
  
  async function updateBalance(account) {
    const weiBalance = await web3.eth.getBalance(account);
    const ethBalance = web3.utils.fromWei(weiBalance, 'ether');
    setBalance(ethBalance);
  }
  






  // Section 1: Deployment

  useEffect(() => {
    loadAccount();
  }, []);
  

  const [offerPriceDecrement, setOfferPriceDecrement] = useState('2');
  const [nft, setNft] = useState('0x963926852cf350b1CE8e51997e49d142e2B4Ce7f'); //default nft contract address
  const [nftId, setNftId] = useState('1'); //default nft id
  const [numBlocksAuctionOpen, setNumBlocksAuctionOpen] = useState('');
  const [reservePrice, setReservePrice] = useState('');
  const [deployedContractAddress, setDeployedContractAddress] = useState('');

  
  const [showInfoAddress, setShowInfoAddress] = useState('');
  const [showInfo, setShowInfo] = useState(null);

  

  const [contractInstance, setContractInstance] = useState(null);


  async function loadAccount() {
    const accounts = await web3.eth.getAccounts();
    setAccount(accounts[0]);
    updateBalance(accounts[0]);
  }



  async function handleDeploy(event) {
    event.preventDefault();

    const manuallyDeployedAddress = '0xfaF9EF56DDFe16A63295657990f1723f7568A345'
    setDeployedContractAddress(manuallyDeployedAddress);
    
  
    if (!account) {
      setErrorMsg('Connect to MetaMask before deploying the contract.');
      return;
    }
    console.log('NFT Address:', nft);
  
    const accounts = await web3.eth.getAccounts();
    const seller = accounts[0];

    const BasicDutchAuctionContract = new web3.eth.Contract(BasicDutchAuctionABI);
  
    const deployTx = BasicDutchAuctionContract.deploy({
      data: BasicDutchAuctionBytecode,
      arguments: [
        web3.utils.toWei(initialPrice.toString(), 'ether'),
        parseInt(offerPriceDecrement),
        parseInt(numBlocksAuctionOpen),
        nft, // The address of the NFT contract
        parseInt(nftId),
      ],
    });
  
    const gas = await deployTx.estimateGas();
    const gasPrice = await web3.eth.getGasPrice();
  
    console.log('Deploying BasicDutchAuction contract...');
    deployTx.send({
      from: seller,
      gas: gas,
      gasPrice: gasPrice,
    })
    .on('transactionHash', function(hash){
      console.log('Transaction Hash:', hash);
    })
    .on('receipt', function(receipt){
      console.log('Receipt:', receipt);
      setDeployedContractAddress(receipt.contractAddress);
      setContractInstance(new web3.eth.Contract(BasicDutchAuctionABI, receipt.contractAddress));
    })
    .on('error', console.error);
}
  
    
  


  // Section 2: Look up info on an auction
  const [lookupAddress, setLookupAddress] = useState('');
  const [winner, setWinner] = useState('');
  const [constructorParams, setConstructorParams] = useState('');
  const [currentPrice, setCurrentPrice] = useState('');


  const [initialPrice, setInitialPrice] = useState('');
  const [priceDecrement, setPriceDecrement] = useState('');
  const [numBlocks, setNumBlocks] = useState('');


  async function handleShowInfo(event) {
    event.preventDefault();

    const manuallyDeployedAddress = '0xfaF9EF56DDFe16A63295657990f1723f7568A345'
    setDeployedContractAddress(manuallyDeployedAddress);

    const contract = new web3.eth.Contract(BasicDutchAuctionABI, showInfoAddress);

    const [winner, offerPriceDecrement, nft, nftId, numBlocksAuctionOpen, reservePrice] = await Promise.all([
      contract.methods.winner().call(),
      contract.methods.offerPriceDecrement().call(),
      contract.methods.nft().call(),
      contract.methods.nftId().call(),
      contract.methods.numBlocksAuctionOpen().call(),
      contract.methods.reservePrice().call(),
    ]);

    setShowInfo({
      winner,
      offerPriceDecrement,
      nftAddress: nft,
      nftId,
      numBlocksAuctionOpen,
      reservePrice,
      currentPrice: await contract.methods.getPrice().call(),
    });

    
  }

  // Section 3: Submit a bid
  const [bidAddress, setBidAddress] = useState('');
  const [bidAmount, setBidAmount] = useState('');
  const [bidResult, setBidResult] = useState('');

  async function handleBid(event) {
    event.preventDefault();

    const contract = new web3.eth.Contract(BasicDutchAuctionABI, bidAddress);
  
  
    const accounts = await web3.eth.getAccounts();
    const from = accounts[0];
  
    const tx = contract.methods.bid();
    const gas = await tx.estimateGas({ from: from, value: bidAmount });
    const gasPrice = await web3.eth.getGasPrice();
  
    await tx.send({ from: from, value: bidAmount, gas: gas, gasPrice: gasPrice })
      .on('receipt', (receipt) => {
        setBidResult('Bid accepted as winner!');
      })
      .on('error', (error) => {
        setBidResult('Bid not accepted as winner.');
      });
  }
  
  return (
    <div>
      

      <h2>Account Info</h2>
      {isConnected ? (
        <>
          <p>Account: {account}</p>
          <p>Balance: {balance} ETH</p>
          <button onClick={disconnectAccount}>Disconnect</button>
        </>
      ) : (
        <>
          <button onClick={connectAccount}>Connect</button>
          {errorMsg && <p>{errorMsg}</p>}
        </>
      )}

      <h1>Basic Dutch Auction</h1>
  
      <h2>Section 1: Deploy contract</h2>
      <form onSubmit={handleDeploy}>
        <label>Initial Price: </label>
        <input type="number" value={initialPrice} onChange={(e) => setInitialPrice(e.target.value)} /><br />
        <label>Price Decrement: </label>
        <input type="number" value={offerPriceDecrement} onChange={(e) => setOfferPriceDecrement(e.target.value)} /><br />
        <label>Num Blocks Auction Open: </label>
        <input type="number" value={numBlocks} onChange={(e) => setNumBlocks(e.target.value)} /><br />
        <button type="submit">Deploy</button>
      </form>
      {deployedContractAddress && <p>Deployed at address: {deployedContractAddress}</p>}
  
      <h2>Section 2: Look up info on an auction</h2>
      <form onSubmit={handleShowInfo}>
        <label>Address: </label>
        <input type="text" value={showInfoAddress} onChange={(e) => setShowInfoAddress(e.target.value)} /><br />
        <button type="submit">Show Info</button>
      </form>
      {showInfo && (
        <>
          <p>Winner: {winner}</p>
        
          <ul>
            <li>Offer Price Decrement: {showInfo.offerPriceDecrement}</li>
            
            
            <li>Num Blocks Auction Open: {showInfo.numBlocksAuctionOpen}</li>
            
          </ul>
          <p>Current Price: {showInfo.currentPrice}</p>
        </>
      )}
  
      <h2>Section 3: Submit a bid</h2>
          <form onSubmit={handleBid}>
            <label>Address: </label>
            <input type="text" value={bidAddress} onChange={(e) => setBidAddress(e.target.value)} />
            <br />
            <label>Amount: </label>
            <input type="number" value={bidAmount} onChange={(e) => setBidAmount(e.target.value)} />
            <br />
            <button type="submit">Bid</button>
          </form>
          {bidResult && <p>{bidResult}</p>}
    </div>
    );
  }
export default App;
  