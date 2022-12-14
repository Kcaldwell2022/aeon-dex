//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
	string public name;
	string public symbol;
	uint public decimals = 18;
	uint public totalSupply;

	//Stores balances of addresses
	mapping(address => uint) public balanceOf;
	//Stores allowance approved by msg.sender for exchange to spend
	mapping(address => mapping(address => uint)) public allowance;

	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);

	//State variables assigned values on deployment
	constructor(string memory _name, string memory _symbol, uint _totalSupply) {
		name = _name;
		symbol = _symbol;
		totalSupply = _totalSupply * (10**decimals);
		balanceOf[msg.sender] = totalSupply;
	}

	//Transfers funds to provided address
	function transfer(address _to, uint _value) public returns (bool success) {
		require(balanceOf[msg.sender] >= _value, 'Not enough funds');
		_transfer(msg.sender, _to, _value);
		return true;
	}

	//Handles transaction math
	function _transfer(address _from, address _to, uint _value) internal {
		require(_to != address(0), 'Invalid address');
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;
		emit Transfer(_from, _to, _value);
	}

	//Assigns allowance of funds the exchange is allowed to spend for msg.sender, _spender is exchange contract
	function approve(address _spender, uint _value) public returns (bool success) {
		require(_spender != address(0), 'invalid address');
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	//Allows exchange contract to handle transactions, msg.sender is the exchange contract
	function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
		//Exchange contract cannot spend more than the allowance approved by _from address
		require(_value <= allowance[_from][msg.sender]);
		require(_value <= balanceOf[_from]);
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

}
