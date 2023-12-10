// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";


abstract contract CCIPMessageManager is CCIPReceiver {
    error NoMessageReceived();
    error IndexOutOfBound(uint256 providedIndex, uint256 maxIndex);
    error MessageIdNotExist(bytes32 messageId);
    error NotEnoughBalance(uint256, uint256);
    error NothingToWithdraw();

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId,                // The unique ID of the message.
        uint64 indexed destinationChainSelector,  // The chain selector of the destination chain.
        address receiver,                         // The address of the receiver on the destination chain.
        address borrower,                         // The borrower's EOA - would map to a depositor on the source chain.
        Client.EVMTokenAmount tokenAmount,        // The token amount that was sent.
        uint256 fees                              // The fees paid for sending the message.
    );

    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId,           // The unique ID of the message.
        uint64 indexed sourceChainSelector,  // The chain selector of the source chain.
        address sender,                      // The address of the sender from the source chain.
        address depositor                    // The EOA of the depositor on the source chain
    );

    // Struct to hold details of a message.
    struct MessageIn {
        uint64 sourceChainSelector;  // The chain selector of the source chain.
        address sender;              // The address of the sender.
        bytes data;                  // The content of the message.

    }

    // Storage variables.
    bytes32[] public receivedMessages; // Array to keep track of the IDs of received messages.
    mapping(bytes32 => MessageIn) public messageDetail; // Mapping from message ID to MessageIn struct, storing details of each received message.

    LinkTokenInterface linkToken;
    
    constructor(address _router, address link) CCIPReceiver(_router) {
        linkToken = LinkTokenInterface(link);
    }

    function getLatestMessageDetails()
        public
        view
        returns (bytes32, uint64, address, string memory)
    {
        // Get the latest message ID.
        bytes32 messageId = receivedMessages[receivedMessages.length - 1];

        // Get the message details.
        MessageIn memory message = messageDetail[messageId];

        // Return the message details.
        return (messageId, message.sourceChainSelector, message.sender, "");
    }

    function decodePayload(bytes memory payload) internal pure returns (bytes32, bytes32, bytes32, bytes32) {
        require(payload.length >= 128, "Payload too short");

        bytes32 functionSelector;
        bytes32 arg1;
        bytes32 arg2;
        bytes32 arg3;

        assembly {
            functionSelector := mload(add(payload, 32))
            arg1 := mload(add(payload, 64))
            arg2 := mload(add(payload, 96))
            arg3 := mload(add(payload, 128))
        }

        return (functionSelector, arg1, arg2, arg3);
    }
}
