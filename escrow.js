const solc = require('solc');
const fs = require('fs');
const abiDecoder = require('abi-decoder');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

const source = fs.readFileSync('./Escrow.sol');

const compiled = solc.compile(source.toString(), 1);

const bytecode = compiled.contracts[':Escrow'].bytecode;

const abi = JSON.parse(compiled.contracts[':Escrow'].interface);

const Escrow = new web3.eth.Contract(abi);

web3.eth.getAccounts().then(accounts => {
  
  const buyer = accounts[0];
  const seller = accounts[1];
  const arbiter = accounts[2];

  Escrow.deploy({ 
    data: bytecode,
    arguments: [seller, arbiter]
  })
  .send({
    from: buyer,
    gas: 240000,
    gasPrice: '30000000000',
    value: web3.utils.toWei(10, 'ether').toString()
  })
  .on('receipt', receipt => {
    console.log(receipt)
  })
  .then(contract => {
    console.log(contract)
  });
  
});

