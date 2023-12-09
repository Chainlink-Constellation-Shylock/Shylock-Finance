// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CErc20.sol";
import "./ShylockCToken.sol";

/**
 * @title Shylock Finance's CErc20 Contract
 * @notice CTokens which wrap an EIP-20 underlying
 * @author Shylock Finance
 */
contract ShylockCErc20 is CErc20, ShylockCToken {

    function addDaoReserve(uint reserveAmount) external returns (uint) {
        addDaoReserveInternal(reserveAmount);
        return NO_ERROR;
    }

    function addMemberReserve(address dao, uint reserveAmount) external returns (uint) {
        addMemberReserveInternal(dao, reserveAmount);
        return NO_ERROR;
    }

    function withdrawDaoReserve(uint withdrawAmount) external returns (uint) {
        withdrawDaoReserveInternal(withdrawAmount);
        return NO_ERROR;
    }

    function borrow(uint borrowAmount) override external returns (uint) {
        revert ("ShylockCErc20: Default borrow not allowed");
    }

    function borrow(address dao, uint dueTimestamp, uint borrowAmount) external returns (uint) {
        borrowInternal(dao, dueTimestamp, borrowAmount);
        return NO_ERROR;
    }

}
