// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CToken.sol";
import "./ShylockCTokenInterfaces.sol";
import "./ShylockComptrollerInterface.sol";

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

    function borrowInternal(address dao, uint dueTimestamp, uint borrowAmount) internal nonReentrant {
        accrueInterest();
        // borrowFresh emits borrow-specific logs on errors, so we don't need to
        borrowFresh(dao, payable(msg.sender), dueTimestamp, borrowAmount);
    }

    function borrowFresh(address dao, address payable borrower, uint dueTimestamp, uint borrowAmount) internal {
        /* Fail if borrow not allowed */
        uint allowed = comptroller.borrowAllowed(address(this), dao, borrower, borrowAmount);
        if (allowed != 0) {
            revert BorrowComptrollerRejection(allowed);
        }

        /* Verify market's block number equals current block number */
        if (accrualBlockNumber != getBlockNumber()) {
            revert BorrowFreshnessCheck();
        }

        /* Fail gracefully if protocol has insufficient underlying cash */
        if (getCashPrior() < borrowAmount) {
            revert BorrowCashNotAvailable();
        }

        /*
         * We calculate the new borrower and total borrow balances, failing on overflow:
         *  accountBorrowNew = accountBorrow + borrowAmount
         *  totalBorrowsNew = totalBorrows + borrowAmount
         */
        uint accountBorrowsPrev = borrowBalanceStoredInternal(borrower);
        uint accountBorrowsNew = accountBorrowsPrev + borrowAmount;
        uint totalBorrowsNew = totalBorrows + borrowAmount;

        /////////////////////////
        // EFFECTS & INTERACTIONS
        // (No safe failures beyond this point)

        /*
         * We write the previously calculated values into storage.
         *  Note: Avoid token reentrancy attacks by writing increased borrow before external transfer.
        `*/
        accountBorrows[borrower].principal = accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrowsNew;

        /*
         * We invoke doTransferOut for the borrower and the borrowAmount.
         *  Note: The cToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the cToken borrowAmount less of cash.
         *  doTransferOut reverts if anything goes wrong, since we can't be sure if side effects occurred.
         */
        doTransferOut(borrower, borrowAmount);

        /* We emit a Borrow event */
        emit Borrow(borrower, borrowAmount, accountBorrowsNew, totalBorrowsNew);
    }

}