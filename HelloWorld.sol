pragma solidity ^0.4.0;

contract HelloWorld {
  mapping (address => uint) public balances;

  function HelloWorld() {
    balances[msg.sender] = 100000;
  }

  function transfer(address _to, uint _amount) {
    if (balances[msg.sender] < _amount) {
      throw;
    }

    balances[msg.sender] -= _amount;
    balances[_to] += _amount;
  }

}
