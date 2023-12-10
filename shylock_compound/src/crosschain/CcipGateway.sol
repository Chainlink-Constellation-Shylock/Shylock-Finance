// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/ccip/interfaces/IRouterClient.sol";


contract CcipGateway is CCIPReceiver {
    LinkTokenInterface linkToken;

    mapping (address => uint64) public destinationChainSelector;  // tokenAddress => destinationChainSelector
    mapping (address => address) public tokenPoolAddress;         // tokenAddress => tokenPoolAddress
    mapping (uint64 => mapping (address => address)) public tokenAddress; // destinationChainSelector => tokenPoolAddress => tokenAddress
    constructor(address _router, address link) CCIPReceiver(_router) {
        linkToken = LinkTokenInterface(link);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        bytes32 messageId = message.messageId; // fetch the message id
        address sender = abi.decode(message.sender, (address)); // abi-decoding of the sender address

        uint64 sourceChainSelector = message.sourceChainSelector;

        // Call the function to handle the message.
        (bool success, bytes memory returndata) = tokenAddress[sourceChainSelector][sender].call(message.data);
    }

    function sendMessage(
        bytes memory data
    ) external returns (bytes32 messageId) {
        uint64 destinationChain = destinationChainSelector[msg.sender];
        address receiverContract = tokenPoolAddress[msg.sender];

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

    // TODO: Add onlyOwner modifier
    function registerToken(address _tokenAddress, uint64 _destinationChainSelector, address _tokenPoolAddress) public {
        destinationChainSelector[_tokenAddress] = _destinationChainSelector;
        tokenPoolAddress[_tokenAddress] = _tokenPoolAddress;
    }
}