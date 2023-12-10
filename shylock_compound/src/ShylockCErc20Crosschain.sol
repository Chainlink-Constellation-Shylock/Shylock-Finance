// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ShylockCErc20.sol";

/**
 * @title Shylock Finance's Crosschain-CErc20 Contract
 * @notice 
 * @author Shylock Finance
 */


contract ShylockCErc20Crosschain is ShylockCErc20 {

       /**
     * @notice Initialize the new money market
     * @param underlying_ The address of the underlying asset
     * @param comptroller_ The address of the Comptroller
     * @param interestRateModel_ The address of the interest rate model
     * @param initialExchangeRateMantissa_ The initial exchange rate, scaled by 1e18
     * @param name_ ERC-20 name of this token
     * @param symbol_ ERC-20 symbol of this token
     * @param decimals_ ERC-20 decimal precision of this token
     */
    function initialize(address underlying_,
                        ShylockComptrollerInterface comptroller_,
                        InterestRateModel interestRateModel_,
                        uint initialExchangeRateMantissa_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_,
                        address ccipGateWay_) public {
        // CToken initialize does the bulk of the work
        super.initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);
        ccipGateWay = ccipGateWay_;

        // Set underlying and sanity check it
        underlying = underlying_;
        EIP20Interface(underlying).totalSupply();
    }

    function doTransferOut(address to, uint amount) internal {
        bytes4 functionSelector = bytes4(keccak256("doTransferOut(address,uint)"));

        bytes memory data = abi.encodeWithSelector(functionSelector, to, amount);

        (bool success, bytes memory returnData) = ccipGateWay.call(data);

        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}
