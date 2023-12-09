// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MockComptroller {
    // function to execute modifyReputation in ShylockGovernance contract
    function execute(address target, bytes memory data) external returns (bytes memory) {
        (bool success, bytes memory result) = target.call(data);
        require(success, "MockComptroller: execution failed");
        return result;
    }

    function getAccountAllCtokenBalance(address /* account */) external pure returns (uint, uint) {
        return (0, 100);
    }
}