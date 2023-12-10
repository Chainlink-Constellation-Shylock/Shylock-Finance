// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./compound/CErc20.sol";
import "./ShylockCToken.sol";

/**
 * @title Shylock Finance's CErc20 Contract
 * @notice CTokens which wrap an EIP-20 underlying
 * @author Shylock Finance
 */
contract ShylockCErc20 is CErc20, ShylockCToken {
    function getCashPrior() virtual override(CErc20, CToken) internal view returns (uint) {
        EIP20Interface token = EIP20Interface(underlying);
        uint orginalBalance = token.balanceOf(address(this));
        return orginalBalance - totalShylockReserve;
    }

    function addDaoReserve(uint reserveAmount) external returns (uint) {
        addDaoReserveInternal(reserveAmount, 0);
        return NO_ERROR;
    }

    function addMemberReserve(address dao, uint reserveAmount) external returns (uint) {
        addMemberReserveInternal(dao, reserveAmount, 0);
        return NO_ERROR;
    }

    function withdrawDaoReserve(uint withdrawAmount) external returns (uint) {
        withdrawDaoReserveInternal(withdrawAmount, 0);
        return NO_ERROR;
    }

    function borrow(uint borrowAmount) override external returns (uint) {
        revert ("ShylockCErc20: Default borrow not allowed");
    }

    function borrow(address dao, uint dueTimestamp, uint borrowAmount) external returns (uint) {
        borrowInternal(dao, dueTimestamp, borrowAmount, 0);
        return NO_ERROR;
    }
}
