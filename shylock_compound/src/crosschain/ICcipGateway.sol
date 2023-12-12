// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;

abstract contract CcipGatewayInterface {
    function sendMessage(address receiver, bytes memory data) virtual external returns (bytes32);
}