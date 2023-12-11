// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.19;

abstract contract CcipGatewayInterface {
    function sendMessage(address destinationiAddress, bytes memory data) virtual external returns (bytes32);
}