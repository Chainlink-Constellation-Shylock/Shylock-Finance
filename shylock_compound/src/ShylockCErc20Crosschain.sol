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
    function doTransferOut(address payable to, uint amount) internal override(CErc20, CToken){
        bytes32 functionSelector = stringToBytes32("doTransferOut");
        bytes32 data2 = bytes32(amount);
        bytes32 data3 = bytes32(uint256(to));
        bytes memory data = abi.encode(functionSelector, data2, data3);

        sendMessage(to, functionSelector, data2, data3);
    }

    function doTransferIn(address from, address to, uint amount) internal override(CErc20, CToken){
        bytes32 functionSelector = stringToBytes32("doTransferIn");
        bytes32 data2 = bytes32(amount);
        bytes32 data3 = bytes32(uint256(from));
        bytes32 data4 = bytes32(uint256(to));
        bytes memory data = abi.encode(functionSelector, data2, data3, data4);

        sendMessage(to, functionSelector, data2, data3);
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

        if (functionSelector == stringToBytes32("doTransferIn")) {
            uint256 amount = uint256(data2);
            address fromAddress = address(uint160(uint256(data3)));

            doTransferIn(amount, fromAddress, toAddress);
        }
    }
}
