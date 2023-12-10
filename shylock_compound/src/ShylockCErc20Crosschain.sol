// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ShylockCErc20.sol";

/**
 * @title Shylock Finance's Crosschain-CErc20 Contract
 * @notice 
 * @author Shylock Finance
 */


contract ShylockCErc20Crosschain is ShylockCErc20 {

    address immutable public ccipGateWay;

    function doTransferOut(address to, uint amount) internal {
        bytes4 functionSelector = bytes4(keccak256("doTransferOut(address,uint)"));

        bytes memory data = abi.encodeWithSelector(functionSelector, to, amount);

        (bool success, bytes memory returnData) = ccipGateWay.call(data);

        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}
