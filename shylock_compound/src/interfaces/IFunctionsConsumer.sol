// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract IFunctionsConsumer {
    // Common interface for all Consumer contracts used in Shylock Finance
    mapping(string dao => mapping(address user => uint256 score)) public userScore;
}
