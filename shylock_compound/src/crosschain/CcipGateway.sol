// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/ccip/interfaces/IRouterClient.sol";



contract ReceiveGateway is CCIPReceiver {
  constructor(address router) CCIPReceiver(router) {}

  mapping (address => address) public fromToConnection;

  function setFromToConnection(address _from, address _to) external {
    fromToConnection[_from] = _to;
  }

  /// handle a received message
  function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
  ) internal override {

    address sender = abi.decode(any2EvmMessage.sender, (address));
    bytes memory encodedCall = any2EvmMessage.data;

    // Call the function to handle the message.
    (bool success, bytes memory returnData) = fromToConnection[sender].call(encodedCall);
    }

}


contract CcipGateway is ReceiveGateway {
    
    uint64 public destinationChainSelector;
    LinkTokenInterface linkToken;

    constructor(address router, address _linkToken, uint64 _destinationChainSelector) ReceiveGateway(router) {
        linkToken = LinkTokenInterface(_linkToken);
        destinationChainSelector = _destinationChainSelector;
    }

    function sendMessage(
        address receiver,
        bytes memory data
    ) external returns (bytes32 messageId) {
         Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver contract address
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: address(linkToken) // Setting feeToken to LinkToken address, indicating LINK will be used for fees
        });

        // Router(router).deliver(receiveGateway, evm2AnyMessage);

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
