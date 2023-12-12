// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MockConsumer {
    function userScore(string memory /* dao */, address /* member */) external view returns (uint) {
        return 60;
    }
}