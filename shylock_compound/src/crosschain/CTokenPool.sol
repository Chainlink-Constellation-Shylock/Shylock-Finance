// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";


contract CTokenPool {
    IERC20 immutable public token;

    uint64 immutable public destinationChain;
    address immutable public ccipGateWay;

    mapping(address => uint256) public deposits;   // Depsitor Address => amount
    mapping(address => uint256) public borrowings; // Borrower Address => amount

    // event Deposited(address indexed user, address indexed token, uint256 amount);
    // event Withdrawed(address indexed user, address indexed token, uint256 amount);

    constructor(address tokenAddress, address _ccipGateway, uint64 destinationChainSelector) {
        token = IERC20(tokenAddress);
        ccipGateWay = _ccipGateway;
        destinationChain = destinationChainSelector;
    }

    function doTransferOut(uint256 amount, address fromAddress, address toAddress) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[fromAddress] >= amount, "Not enough tokens to transfer");

        deposits[fromAddress] -= amount;

        require(token.transfer(toAddress, amount), "Transfer failed");
    }

    function borrow(uint256 amount, address borrower) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[borrower] >= amount, "Not enough tokens to borrow");

        deposits[borrower] -= amount;
        borrowings[borrower] += amount;

        require(token.transfer(borrower, amount), "Transfer failed");
    }

    /* Message Sending */
    function addDaoReserve(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender] += amount;

        bytes4 functionSelector = bytes4(keccak256("addDaoReserve(uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, amount);
        data = abi.encodePacked(data, msg.sender);

        require(sendMessage(destinationChain, ccipGateWay, data), "Message sending failed");
    }

    function addMemberReserve(address dao, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender] += amount;

        bytes4 functionSelector = bytes4(keccak256("addMemberReserve(address,uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, dao, amount);
        data = abi.encodePacked(data, msg.sender);

        require(sendMessage(destinationChain, ccipGateWay, data), "Message sending failed");
    }
    
    function withdrawDaoReserve(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Not enough tokens to withdraw");

        deposits[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        bytes4 functionSelector = bytes4(keccak256("withdrawDaoReserve(uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, amount);
        data = abi.encodePacked(data, msg.sender);

        require(sendMessage(destinationChain, ccipGateWay, data), "Message sending failed");
    }

    function withdrawMemberReserve(address dao, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Not enough tokens to withdraw");

        deposits[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        bytes4 functionSelector = bytes4(keccak256("withdrawMemberReserve(address,uint)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, dao, amount);
        data = abi.encodePacked(data, msg.sender);
        
        require(sendMessage(destinationChain, ccipGateWay, data), "Message sending failed");
    }
}