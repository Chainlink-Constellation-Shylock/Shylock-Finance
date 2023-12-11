// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/ccip/interfaces/IRouterClient.sol";


contract CcipGateway is CCIPReceiver {
    LinkTokenInterface linkToken;

    uint64 public mainChainSelector;
    address public mainGateway;
    mapping(address => uint64) public addressToChainSelector;
    mapping(uint64 => address) public chainSelectorToGateway;
    mapping(address => address) public fromToConnection;
  
    constructor(address _router, address link) CCIPReceiver(_router) {
        linkToken = LinkTokenInterface(link);
    }

    function setSubChain(uint64 _mainChainSelect, address _mainGateway) external {
        mainChainSelector = _mainChainSelect;
        mainGateway = _mainGateway;
    }

    function setAddressToChainSelector(address _address, uint64 _chainSelector) external {
        addressToChainSelector[_address] = _chainSelector;
    }

    function setFromToConnection(address _from, address _to) external {
        fromToConnection[_from] = _to;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        bytes32 messageId = message.messageId; // fetch the message id
        address sender = abi.decode(message.sender, (address)); // abi-decoding of the sender address

        uint64 sourceChainSelector = message.sourceChainSelector;

        // Get the message data.
        bytes memory encodedCall = message.data;

        // Call the function to handle the message.
        (bool success, bytes memory returnData) = fromToConnection[sender].call(encodedCall);
    }

    function sendMessage(
        address destinationAddress,
        bytes memory data
    ) external returns (bytes32 messageId) {
        uint64 destinationChainSelector;
        address destinationGateway;
        if(mainChainSelector != 0 && mainGateway != address(0)) {
            destinationChainSelector = mainChainSelector;
            destinationGateway = mainGateway;
        } else {
            destinationChainSelector = addressToChainSelector[destinationAddress];
            destinationGateway = chainSelectorToGateway[destinationChainSelector];
        }

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(destinationGateway), // ABI-encoded receiver contract address
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
        uint256 fees = router.getFee(destinationChainSelector, evm2AnyMessage);

        // Approve the Router to pay fees in LINK tokens on contract's behalf.
        linkToken.approve(address(router), fees);

        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend(destinationChainSelector, evm2AnyMessage);

        // TODO: Emit an event with message details

        // Return the message ID
        return messageId;
    }

}