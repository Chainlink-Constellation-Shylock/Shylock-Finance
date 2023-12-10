// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CErc20.sol";
import "./ShylockCTokenCrosschain.sol";

/**
 * @title Shylock Finance's CErc20 Contract
 * @notice CTokens which wrap an EIP-20 underlying
 * @author Shylock Finance
 */
contract ShylockCErc20Crosschain is CErc20, ShylockCTokenCrosschain {

    function addDaoReserve(address daoAddress, uint reserveAmount) internal returns (uint) {
        addDaoReserveInternal(daoAddress, reserveAmount);
        return NO_ERROR;
    }

    function addMemberReserve(address memberAddress, address dao, uint reserveAmount) external returns (uint) {
        addMemberReserveInternal(memberAddress, dao, reserveAmount);
        return NO_ERROR;
    }

    function withdrawDaoReserve(uint withdrawAmount) external returns (uint) {
        withdrawDaoReserveInternal(withdrawAmount, chainId);
        return NO_ERROR;
    }

    function borrow(uint borrowAmount) override external returns (uint) {
        revert ("ShylockCErc20: Default borrow not allowed");
    }

    function borrow(address dao, uint dueTimestamp, uint borrowAmount) external returns (uint) {
        borrowInternal(dao, dueTimestamp, borrowAmount, chainId);
        return NO_ERROR;
    }

    function doTransferOut(address payable to, uint amount, uint64 chainId) virtual internal {
        sendMessage(chainId, chainIdToAddress[chainId], stringToBytes32("TransferOut"), amount, to, bytes32(0));
    }

    function sendMessage(
        uint64 destinationChain,
        address receiverAddress,
        bytes32 functionSelector,
        bytes32 data2,
        bytes32 data3,
        bytes32 data4
    ) internal returns (bytes32 messageId) {
        bytes memory data = abi.encode(functionSelector, data2, data3, data4);

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

        if (functionSelector == stringToBytes32("addDaoReserve")) {
            uint256 reserveAmount = uint256(data2);

            addDaoReserve(sender, reserveAmount);
        } else if (functionSelector == stringToBytes32("addMemberReserve")) {
            uint256 reserveAmount = uint256(data2);

            addMemberReserve(sender, reserveAmount);
        } else if (functionSelector == stringToBytes32("withdrawDaoReserve")) {
            uint256 amount = uint256(data2);

            withdrawDaoReserve(amount);
        } else if (functionSelector == stringToBytes32("withdrawMemberReserve")) {
            uint256 amount = uint256(data2);

            withdrawMemberReserve(amount);
        } else {
            revert("Invalid function selector");
        }
    }

    function stringToBytes32(string memory source) public pure returns (bytes32) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToAddress(bytes32 _bytes32) public pure returns (address) {
        return address(uint160(uint256(_bytes32)));
    }
}
