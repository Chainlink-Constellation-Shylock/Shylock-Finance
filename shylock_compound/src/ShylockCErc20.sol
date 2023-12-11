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
   /**
     * @notice Construct a new money market
     * @param underlying_ The address of the underlying asset
     * @param comptroller_ The address of the Comptroller
     * @param interestRateModel_ The address of the interest rate model
     * @param initialExchangeRateMantissa_ The initial exchange rate, scaled by 1e18
     * @param name_ ERC-20 name of this token
     * @param symbol_ ERC-20 symbol of this token
     * @param decimals_ ERC-20 decimal precision of this token
     * @param admin_ Address of the administrator of this token
     */
    constructor(address underlying_,
                ShylockComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_) {
        // Creator of the contract is admin during initialization
        admin = payable(msg.sender);

        // // First delegate gets to initialize the delegator (i.e. storage contract)
        // delegateTo(implementation_, abi.encodeWithSignature("initialize(address,address,address,uint256,string,string,uint8)",
        //                                                     underlying_,
        //                                                     comptroller_,
        //                                                     interestRateModel_,
        //                                                     initialExchangeRateMantissa_,
        //                                                     name_,
        //                                                     symbol_,
        //                                                     decimals_));

        // // New implementations always get set via the settor (post-initialize)
        // _setImplementation(implementation_, false, becomeImplementationData);
        super.initialize(underlying_,
                        comptroller_,
                        interestRateModel_,
                        initialExchangeRateMantissa_,
                        name_,
                        symbol_,
                        decimals_);

        // Set the proper admin now that initialization is done
        admin = admin_;
    }



    function getCashPrior() virtual override(CErc20, CToken) internal view returns (uint) {
        EIP20Interface token = EIP20Interface(underlying);
        uint orginalBalance = token.balanceOf(address(this));
        return orginalBalance - totalShylockReserve;
    }

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

    function withdrawMemberReserve(address dao, uint withdrawAmount) external returns (uint) {
        withdrawMemberReserveInternal(dao, withdrawAmount);
        return NO_ERROR;
    }

    function borrow(uint borrowAmount) override external returns (uint) {
        revert ("ShylockCErc20: Default borrow not allowed");
    }

    function borrow(address dao, uint dueTimestamp, uint borrowAmount) external returns (uint) {
        borrowInternal(dao, dueTimestamp, borrowAmount);
        return NO_ERROR;
    }

    function repayBorrow(uint repayAmount) override external returns (uint) {
        revert ("ShylockCErc20: Default repayBorrow not allowed");
    }

    function repayBorrow(address dao, uint repayAmount, uint index) external returns (uint) {
        repayBorrowInternal(dao, repayAmount, index);
        return NO_ERROR;
    }
}
