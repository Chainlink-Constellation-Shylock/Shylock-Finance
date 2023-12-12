// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CcipGateway} from "./CcipGateway.sol";
import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";


abstract contract IERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
}

contract CTokenPool {
    IERC20 immutable public token;

    CcipGateway immutable public ccipGateWay;

    address public destGateWay;

    mapping(address => uint256) public deposits;   // Depsitor Address => amount
    mapping(address => uint256) public borrowings; // Borrower Address => amount

    // event Deposited(address indexed user, address indexed token, uint256 amount);
    // event Withdrawed(address indexed user, address indexed token, uint256 amount);

    constructor(address tokenAddress, address _destGateWay, CcipGateway _ccipGateway) {
        token = IERC20(tokenAddress);
        destGateWay = _destGateWay;
        ccipGateWay = _ccipGateway;
    }

    modifier onlyGateway() {
        require(msg.sender == address(ccipGateWay), "Only gateway can call this function");
        _;
    }

    function doTransferOut(address to, uint amount) public onlyGateway {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[to] >= amount, "Not enough tokens to transfer");

        deposits[to] -= amount;

        require(token.transfer(to, amount), "Transfer failed");
    }

    /* Message Sending */
    function addDaoReserve(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender] += amount;

        bytes4 functionSelector = bytes4(keccak256("addDaoReserve(uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, amount);
        data = abi.encodePacked(data, msg.sender);

        ccipGateWay.sendMessage(destGateWay, data);
    }

    function addMemberReserve(address dao, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender] += amount;

        bytes4 functionSelector = bytes4(keccak256("addMemberReserve(address,uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, dao, amount);
        data = abi.encodePacked(data, msg.sender);

        ccipGateWay.sendMessage(destGateWay, data);
    }
    
    function withdrawDaoReserve(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Not enough tokens to withdraw");

        deposits[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        bytes4 functionSelector = bytes4(keccak256("withdrawDaoReserve(uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, amount);
        data = abi.encodePacked(data, msg.sender);

        ccipGateWay.sendMessage(destGateWay, data);
    }

    function withdrawMemberReserve(address dao, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Not enough tokens to withdraw");

        deposits[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        bytes4 functionSelector = bytes4(keccak256("withdrawMemberReserve(address,uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, dao, amount);
        data = abi.encodePacked(data, msg.sender);
        
        ccipGateWay.sendMessage(destGateWay, data);
    }

    function borrow(address dao, uint dueTimestamp, uint amount) public {
        require(amount > 0, "Amount must be greater than 0");
        
        bytes4 functionSelector = bytes4(keccak256("borrow(address,uint256,uint256)"));
        bytes memory data = abi.encodeWithSelector(functionSelector,dao,dueTimestamp,amount);
        data = abi.encodePacked(data, msg.sender);

        ccipGateWay.sendMessage(destGateWay, data);
    }

    function repayBorrow(address dao, uint amount, uint index) public {
        require(amount > 0, "Amount must be greater than 0");

        bytes4 functionSelector = bytes4(keccak256("repayBorrow(address,uint256,uint256)"));
        bytes memory data = abi.encodeWithSelector(functionSelector,dao,amount,index);
        data = abi.encodePacked(data, msg.sender);

        ccipGateWay.sendMessage(destGateWay, data);
    }

}