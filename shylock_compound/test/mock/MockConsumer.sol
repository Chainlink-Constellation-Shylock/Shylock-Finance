// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MockConsumer {
    mapping(string dao => mapping(address member => uint score)) public userScore;

    function setScore(string memory dao, address member, uint _value) external {
        userScore[dao][member] = _value;
    }
}