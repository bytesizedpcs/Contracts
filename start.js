const solc = require('solc')
const fs = require('fs')
const abiDecoder = require('abi-decoder')
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

// get the contract source
const source = fs.readFileSync('./HelloWorld.sol')

// compile the contract using solc
const compiled = solc.compile(source.toString(), 1)

// get bytecode from compiled contract
const bytecode = compiled.contracts[':HelloWorld'].bytecode

// get the interface code from compiled contract
const abi = JSON.parse(compiled.contracts[':HelloWorld'].interface)

// create new contract with interface code
const HelloWorld = new web3.eth.Contract(abi)

// decode the abi
abiDecoder.addABI(abi)

let allAccounts;

// get accounts from provider
web3.eth.getAccounts().then(accounts => {
  allAccounts = accounts

  // deploy the contract to the network
  HelloWorld.deploy({ data: bytecode })

  // meta data for contract sending
  .send({
    from: accounts[0],
    gas: 250000,
    gasPrice: '30000000000000'
  })

  // get meta data from the processed contract
  .on('receipt', receipt => {

    HelloWorld.options.address = receipt.contractAddress;
    // use the method from contract
    // to send 10 eth from account 1
    HelloWorld.methods.transfer(accounts[1], 10)

    // send method from account 1
    .send({ from: accounts[0] })

    .then(transaction => {
      // log out the transaction
      console.log(`Transfer logged: ${transaction.transactionHash}`)

      // save blockhash to variable
      let blockhash = transaction.blockHash

      // return the newly created block
      return web3.eth.getBlock(blockhash, true)
    })
    .then(block => {

      // for every transaction in that block
      // decode the params from the transactions
      block.transactions.forEach(transaction => {
        console.log(abiDecoder.decodeMethod(transaction.input))
      })

      // get the balances for all the accounts
      allAccounts.forEach(account => {
        HelloWorld.methods.balances(account).call({ from: allAccounts[0] })
        .then(amount => {
          console.log(`${account}: ${amount}`)
        })
      })
    })
  })
})
