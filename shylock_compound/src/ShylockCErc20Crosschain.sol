// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ShylockCErc20.sol";
import "./crosschain/CCIPMessageManager.sol";

/**
 * @title Shylock Finance's Crosschain-CErc20 Contract
 * @notice 
 * @author Shylock Finance
 */


contract ShylockCErc20Crosschain is ShylockCErc20, CCIPMessageManager {

    uint64 destinationChainSelector;
    address tokenPoolAddress;

    constructor(address _router, address link, uint64 _destinationChainSelector, address _tokenPoolAddress) CCIPMessageManager(_router, link) {
        destinationChainSelector = _destinationChainSelector;
        tokenPoolAddress = _tokenPoolAddress;
    }

    function doTransferOut(address to, uint amount) internal override(CErc20, CToken){
        bytes32 functionSelector = stringToBytes32("doTransferOut");
        bytes32 data2 = bytes32(amount);
        bytes32 data3 = bytes32(uint256(uint160(to)));

        sendMessage(destinationChainSelector, tokenPoolAddress, functionSelector, data2, data3, bytes32(0));
    }

    // function doTransferIn(address from, address to, uint amount) internal override(CErc20, CToken){
        
    // }

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

        (
            bytes32 functionSelector,
            bytes32 data2,
            bytes32 data3,
            bytes32 data4
        ) = decodePayload(data);

        if (functionSelector == stringToBytes32("doTransferIn")) {
            uint256 amount = uint256(data2);
            address fromAddress = address(uint160(uint256(data3)));
            address toAddress = address(uint160(uint256(data4)));

            // doTransferIn(amount, fromAddress, toAddress);
        }
    }
}
