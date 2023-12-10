// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/ccip/interfaces/IRouterClient.sol";


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

    function sendMessage(
        uint64 destinationChain,
        address receiverAddress,
        bytes32 functionSelector,
        bytes32 data2,
        bytes32 data3
    ) internal returns (bytes32 messageId) {
        bytes32 senderAddress = addressToBytes32(address(this));
        bytes memory data = abi.encode(functionSelector, senderAddress, data2, data3);

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiverAddress), // ABI-encoded receiver contract address
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: address(linkToken) // Setting feeToken to LinkToken address, indicating LINK will be used for fees
        });

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the message. Fee paid in LINK.
        uint256 fees = router.getFee(destinationChain, evm2AnyMessage);

        // Approve the Router to pay fees in LINK tokens on contract's behalf.
        linkToken.approve(address(router), fees);

        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend(destinationChain, evm2AnyMessage);

        // TODO: Emit an event with message details

        // Return the message ID
        return messageId;
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

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function addressToBytes32(address source) public pure returns (bytes32 result){
        return bytes32(uint256(uint160(source)));
    }
}
