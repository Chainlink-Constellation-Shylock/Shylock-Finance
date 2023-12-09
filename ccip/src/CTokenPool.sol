// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/interfaces/LinkTokenInterface.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/ccip/interfaces/IRouterClient.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {CCIPMessageManager} from "./CCIPMessageManager.sol";

contract CTokenPool is CCIPMessageManager {
    uint64 sepoliaChainSelector = 16015286601757825753;

    mapping(address => mapping(address => uint256)) public deposits;   // Depsitor Address => Deposited Token Address ==> amount
    mapping(address => mapping(address => uint256)) public borrowings; // Depsitor Address => Borrowed Token Address ==> amount

    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawed(address indexed user, address indexed token, uint256 amount);

    constructor(address _router, address link) CCIPMessageManager(_router, link) {}

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        bytes32 messageId = message.messageId; // fetch the message id
        address sender = abi.decode(message.sender, (address)); // abi-decoding of the sender address

        // Get the message data.
        bytes memory data = message.data;

        // // Get the message token.
        // address token = data.tokenAmounts[0].token;
        // uint256 amount = data.tokenAmounts[0].amount;

        // Store the message details.
        messageDetail[messageId] = MessageIn({
            sourceChainSelector: message.sourceChainSelector,
            sender: sender,
            // token: token,
            // amount: amount,
            data: data
        });

        // Add the message ID to the array of received messages.
        receivedMessages.push(messageId);

        // TODO: Emit an event with the message details.

        (
            bytes32 functionSelector,
            bytes32 arg1,
            bytes32 arg2,
            bytes32 arg3
        ) = decodePayload(data);

        if (functionSelector == stringToBytes32("Lend")) {
            address tokenAddress = address(uint160(uint256(arg1)));
            uint256 amount = uint256(arg2);
            address toAddress = address(uint160(uint256(arg3)));

            lend(tokenAddress, toAddress, amount);
        } else if (functionSelector == stringToBytes32("Withdraw")) {
            address tokenAddress = address(uint160(uint256(arg1)));
            uint256 amount = uint256(arg2);

            withdraw(tokenAddress, amount);
        } else {
            revert("Invalid function selector");
        }
    }

    function sendMessage(
        address receiverAddress,
        bytes32 functionSelector,
        bytes32 arg1,
        bytes32 arg2
    ) internal returns (bytes32 messageId) {
        bytes32 senderAddress = bytes32(uint256(uint160(msg.sender)));
        bytes memory data = abi.encode(functionSelector, senderAddress, arg1, arg2);

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
        uint256 fees = router.getFee(sepoliaChainSelector, evm2AnyMessage);

        // Approve the Router to pay fees in LINK tokens on contract's behalf.
        linkToken.approve(address(router), fees);

        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend(sepoliaChainSelector, evm2AnyMessage);

        // TODO: Emit an event with message details

        // Return the message ID
        return messageId;
    }

    function deposit(address receiverAddress, address tokenAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);

        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposits[msg.sender][tokenAddress] += amount;
        emit Deposited(msg.sender, tokenAddress, amount);

        bytes32 tokenAddressBytes32 = bytes32(uint256(uint160(tokenAddress)));
        bytes32 amountBytes32 = bytes32(amount);

        // TODO: sendMessage로 메시지를 comptroller로 보내고, comptroller에서 cToken을 mint
        require(sendMessage(receiverAddress, stringToBytes32("Deposit"), tokenAddressBytes32, amountBytes32) != 0, "sendMessage Failed");
    }
    
    function withdraw(address tokenAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);

        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender][tokenAddress] >= amount, "Not enough tokens to redeem");

        deposits[msg.sender][tokenAddress] -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawed(msg.sender, tokenAddress, amount);
    }

    function lend(address tokenAddress, address toAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);
        require(amount > 0, "Amount must be greater than 0");

        borrowings[toAddress][tokenAddress] += amount;

        require(token.transferFrom(address(this), toAddress, amount), "Transfer failed");
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens available to transfer");
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
}