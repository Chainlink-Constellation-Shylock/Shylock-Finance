
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";


contract ReciveContract {
  address public receiveGateway;
  function setReciverGateway(address _receiveGateway) public {
    receiveGateway = _receiveGateway;
  }

  event Ping(string text, address sender);
  function ping(string memory text) public {
    emit Ping(text, msg.sender);
  }
}

contract ReceiveGateway {

  mapping (address => address) public fromToConnection;

  function setFromToConnection(address _from, address _to) external {
    fromToConnection[_from] = _to;
  }

  /// handle a received message
  function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) public {
        // s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        // s_lastReceivedText = abi.decode(any2EvmMessage.data, (string)); // abi-decoding of the sent text

        // emit MessageReceived(
        //     any2EvmMessage.messageId,
        //     any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
        //     abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
        //     abi.decode(any2EvmMessage.data, (string))
        // );
                // Get the message data.
        address sender = abi.decode(any2EvmMessage.sender, (address));
        bytes memory encodedCall = any2EvmMessage.data;

        // Call the function to handle the message.
        (bool success, bytes memory returnData) = fromToConnection[sender].call(encodedCall);
    }
}

contract Router {
  //   struct Any2EVMMessage {
  //   bytes32 messageId; // MessageId corresponding to ccipSend on source.
  //   uint64 sourceChainSelector; // Source chain selector.
  //   bytes sender; // abi.decode(sender) if coming from an EVM chain.
  //   bytes data; // payload sent in original message.
  //   EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  // }
  function deliver(address receiveGateway, Client.EVM2AnyMessage memory orginMessage) public {
    Client.Any2EVMMessage memory message = Client.Any2EVMMessage({
        messageId: bytes32(0),
        sourceChainSelector: uint64(0),
        sender: abi.encode(msg.sender),
        data: orginMessage.data,
        destTokenAmounts : new Client.EVMTokenAmount[](0)
    });
    ReceiveGateway(receiveGateway)._ccipReceive(message);
  }
}

contract Sender {
    address public receiveGateway;
    function setReciverGateway(address _receiveGateway) public {
        receiveGateway = _receiveGateway;
    }
    address public router;
    function setRouter(address _router) public {
        router = _router;
    }

    function sendMessage(
        address receiveGateway,
        address router,
        address receiver,
        bytes memory data
    ) public {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver contract address
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: address(0) // Setting feeToken to LinkToken address, indicating LINK will be used for fees
        });
        
        Router(router).deliver(receiveGateway, evm2AnyMessage);
    }
    function triggerPing(address target, string memory text) public {
        bytes4 functionSelector = bytes4(keccak256("ping(string)"));
        bytes memory data = abi.encodeWithSelector(functionSelector, text);
        // data = abi.encodePacked(data, msg.sender);
        sendMessage(receiveGateway, router, target, data);
    }

}



contract CrosschainTest {
  function setUp() public {
  }
  function testPing() public {
    ReciveContract receiveContract = new ReciveContract();
    ReceiveGateway receiveGateway = new ReceiveGateway();
    receiveContract.setReciverGateway(address(receiveGateway));
    Sender sender = new Sender();
    receiveGateway.setFromToConnection(address(sender), address(receiveContract));
    sender.setReciverGateway(address(receiveGateway));
    sender.setRouter(address(new Router()));
    sender.triggerPing(address(receiveContract), "hello");
  }
  
}