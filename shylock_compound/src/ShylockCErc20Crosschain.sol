// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ShylockCErc20.sol";

/**
 * @title Shylock Finance's Crosschain-CErc20 Contract
 * @notice 
 * @author Shylock Finance
 */


contract ShylockCErc20Crosschain is ShylockCErc20 {

    constructor(address underlying_,
                ShylockComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_,
                address ccipGateWay_
                ) ShylockCErc20(underlying_,
                                                        comptroller_,
                                                        interestRateModel_,
                                                        initialExchangeRateMantissa_,
                                                        name_,
                                                        symbol_,
                                                        decimals_,
                                                        admin_) {
                ccipGateWay = ccipGateWay_;
    }

    function doTransferOut(address to, uint amount) internal {
        bytes4 functionSelector = bytes4(keccak256("doTransferOut(address,uint)"));

        bytes memory data = abi.encodeWithSelector(functionSelector, to, amount);

        (bool success, bytes memory returnData) = ccipGateWay.call(data);

        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}
