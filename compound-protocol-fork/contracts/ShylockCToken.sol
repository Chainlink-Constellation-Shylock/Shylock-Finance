// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CToken.sol";
import "./ShylockCTokenInterfaces.sol";

/**
 * @title Shylock Finance's CToken Contract
 * @notice Abstract base for CTokens
 * @author Shylock Finance
 */

abstract contract ShylockCToken is CToken, ShylockCTokenInterface {

    function addDaoReserveInternal(uint reserveAmount) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.addDaoReserveAllowed(address(this), msg.sender, reserveAmount);
        if (allowed != 0) {
            revert addDaoReserveComptrollerRejection(allowed);
        }

        uint actualReserveAmount = doTransferIn(msg.sender, reserveAmount);

        underlyingReserves[msg.sender] = add_(underlyingReserves[msg.sender], actualReserveAmount);

        emit AddDaoReserve(msg.sender, actualReserveAmount, underlyingReserves[msg.sender]);

    }

    function addMemberReserveInternal(uint reserveAmount) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.addMemberReserveAllowed(address(this), msg.sender, reserveAmount);
        if (allowed != 0) {
            revert addMemberReserveComptrollerRejection(allowed);
        }
        
        uint actualReserveAmount = doTransferIn(msg.sender, reserveAmount);

        underlyingReserves[msg.sender] = add_(underlyingReserves[msg.sender], actualReserveAmount);

        emit AddMemberReserve(msg.sender, actualReserveAmount, underlyingReserves[msg.sender]);

    }


}