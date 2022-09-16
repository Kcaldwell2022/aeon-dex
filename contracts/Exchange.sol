//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
//Token contract imported
import "./Token.sol";

contract Exchange {

	address public feeAccount;
	uint public feePercent; 
	uint public orderCount;

	//Stores how much of each token addresses have currently deposited in exchange contract
	mapping(address => mapping(address => uint)) public tokens;
	//Stores Order structs by uint orderCount
	mapping(uint => _Order) public orders;
	//Stores ID's of cancelled orders
	mapping(uint => bool) public orderCancelled;
	//Stores ID's of filled orders
	mapping(uint => bool) public orderFilled;


	event Deposit(address token, address user, uint amount, uint balance);
	event Withdrawal(address token, address user, uint amount, uint balance);
	event Order(uint id, address user, address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint timestamp);
	event Cancel(uint id, address user, address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint timestamp);
	event Trade(uint256 id, address user, address tokenGet, uint256 amountGet, address tokenGive, uint256 amountGive, address creator, uint256 timestamp);

	//user = address that called makeOrder function
	struct _Order {
		uint id;
		address user;
		address tokenGet;
		uint amountGet;
		address tokenGive;
		uint amountGive;
		uint timestamp;
	}

	//Exchange feePercent and the address that collects transaction fees are assigned on deployment
	constructor(address _feeAccount, uint _feePercent) {
		feeAccount = _feeAccount;
		feePercent = _feePercent;
	}

	//Calls transferFrom function from Token contract, transfers tokens to exchange contract from msg.sender
	function depositToken(address _token, uint _amount) public {
		require(Token(_token).transferFrom(msg.sender, address(this), _amount));
		tokens[_token][msg.sender] += _amount;
		emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}

	//Calls transfer function from Token contract, returns deposited tokens to msg.sender
	function withdrawToken(address _token, uint _amount) public {
		require(tokens[_token][msg.sender] >= _amount);
		Token(_token).transfer(msg.sender, _amount);
		tokens[_token][msg.sender] -= _amount;
		emit Withdrawal(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}

	//Returns balance of users tokens that are currently deposited
	function balanceOf(address _token, address _user) public view returns (uint) {
		return tokens[_token][_user];
	}

	//Creates Order structs, _tokenGet = token they want to receive, _tokenGive = token they want to spend
	function makeOrder(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive) public {
		orderCount++;
		orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);
		emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);
	}

	//Adds Order with corresponding _id to orderCancelled mapping, Orders in this mapping cannot be filled
	function cancelOrder(uint _id) public {
		_Order storage _order = orders[_id];
		require(address(_order.user) == msg.sender);
		require(_order.id == _id);
		orderCancelled[_id] = true;
		emit Cancel(_order.id, msg.sender, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive, block.timestamp);
	}

	//Fills created order and adds them to orderFilled mapping, calls _trade function
	function fillOrder(uint _id) public {
		require(_id > 0 && _id <= orderCount, 'Order does not exist');
		require(!orderFilled[_id]);
		require(!orderCancelled[_id]);
		_Order storage _order = orders[_id];
		_trade(_order.id, _order.user, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive);
		orderFilled[_order.id] = true;
	}

	//Handles transaction math
	function _trade(uint _orderId, address _user, address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive) internal {
		//Fee is paid by user who filled order (msg.sender)
		//Fee is deducted from _amountGet
		uint _feeAmount = (_amountGet * feePercent) / 100;
		//Execute trade
		//msg.sender is the user who fills the order(tokenGet is deducted), while _user is who created the order (tokenGet is added)
		tokens[_tokenGet][msg.sender] -= (_amountGet + _feeAmount);
		tokens[_tokenGet][_user] += _amountGet;

		//Charge fee
		tokens[_tokenGet][feeAccount] += _feeAmount;

		//msg.sender is the user who fills the order(tokenGive is added), while _user is who created the order (tokenGive is deducted)
		tokens[_tokenGive][_user] -= _amountGive;
		tokens[_tokenGive][msg.sender] += _amountGive;

		emit Trade(_orderId, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, _user, block.timestamp);
	}
}
