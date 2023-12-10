// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {CCIPMessageManager} from "./CCIPMessageManager.sol";

contract CTokenPool is CCIPMessageManager {
    uint64 immutable public destinationChain;
    IERC20 immutable public token;
    address immutable public cTokenAddress;

    mapping(address => uint256) public deposits;   // Depsitor Address => amount
    mapping(address => uint256) public borrowings; // Borrower Address => amount

    // event Deposited(address indexed user, address indexed token, uint256 amount);
    // event Withdrawed(address indexed user, address indexed token, uint256 amount);

    constructor(address _router, address link, address tokenAddress, address destinationAddress, uint64 destinationChainSelector) CCIPMessageManager(_router, link) {
        destinationChain = destinationChainSelector;
        token = IERC20(tokenAddress);
        cTokenAddress = destinationAddress;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        bytes32 messageId = message.messageId; // fetch the message id
        address sender = abi.decode(message.sender, (address)); // abi-decoding of the sender address

        // Get the message data.
        bytes memory data = message.data;

        // Store the message details.
        messageDetail[messageId] = MessageIn({
            sourceChainSelector: message.sourceChainSelector,
            sender: sender,
            data: data
        });

        // Add the message ID to the array of received messages.
        receivedMessages.push(messageId);

        // TODO: Emit an event with the message details.

        (
            bytes32 functionSelector,
            bytes32 data2,
            bytes32 data3,
            bytes32 data4
        ) = decodePayload(data);

        if (functionSelector == stringToBytes32("doTransferOut")) {
            uint256 amount = uint256(data2);
            address fromAddress = sender;
            address toAddress = address(uint160(uint256(data3)));

            doTransferOut(amount, fromAddress, toAddress);
        } else {
            revert("Invalid function selector");
        }
    }

    function addDaoReserve(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender] += amount;

        require(sendMessage(destinationChain, cTokenAddress, stringToBytes32("addDaoReserve"), bytes32(amount), bytes32(0)) != 0, "Deposit message sending Failed");
    }

    function addMemberReserve(address dao, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender] += amount;

        require(sendMessage(destinationChain, cTokenAddress, stringToBytes32("addMemberReserve"), bytes32(amount), bytes32(0)) != 0, "Deposit message sending Failed");
    }

    function doTransferOut(uint256 amount, address fromAddress, address toAddress) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[fromAddress] >= amount, "Not enough tokens to transfer");

        deposits[fromAddress] -= amount;

        require(token.transfer(toAddress, amount), "Transfer failed");
    }
    
    function withdrawDaoReserve(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Not enough tokens to withdraw");

        deposits[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        require(sendMessage(destinationChain, cTokenAddress, stringToBytes32("withdrawDaoReserve"), bytes32(amount), bytes32(0)) != 0, "Withdraw message sending Failed");
    }

    function withdrawMemberReserve(address dao, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Not enough tokens to withdraw");

        deposits[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        require(sendMessage(destinationChain, cTokenAddress, stringToBytes32("withdrawMemberReserve"), bytes32(amount), bytes32(0)) != 0, "Withdraw message sending Failed");
    }
}