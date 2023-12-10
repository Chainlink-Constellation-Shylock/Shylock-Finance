// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CToken.sol";
import "./ShylockCTokenInterfaces.sol";
import "./ShylockComptrollerInterface.sol";
import "./ShylockComptrollerStorage.sol";

/**
 * @title Shylock Finance's CToken Contract
 * @notice Abstract base for CTokens
 * @author Shylock Finance
 */


abstract contract ShylockCTokenCrosschain is CToken, ShylockCTokenInterface {

    mapping(uint64 => address) public chainIdToAddress;

    constructor() {
        chainIdToAddress[0] = address(this);
    }

    function doTransferOut_Crosschain(address payable to, uint amount, uint64 chainId) virtual internal;
    
    function addDaoReserveInternal(address daoAddress, uint reserveAmount) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.addDaoReserveAllowed(address(this), daoAddress, reserveAmount);
        if (allowed != 0) {
            revert addDaoReserveComptrollerRejection(allowed);
        }

        underlyingReserve[daoAddress] = add_(underlyingReserve[daoAddress], reserveAmount);

        emit AddDaoReserve(daoAddress, reserveAmount, underlyingReserve[daoAddress]);
    }

    function addMemberReserveInternal(address memberAddress, address dao, uint reserveAmount) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.addMemberReserveAllowed(address(this), dao, memberAddress, reserveAmount);
        if (allowed != 0) {
            revert addMemberReserveComptrollerRejection(allowed);
        }

        underlyingReserve[memberAddress] = add_(underlyingReserve[memberAddress], reserveAmount);

        emit AddMemberReserve(memberAddress, reserveAmount, underlyingReserve[memberAddress]);
    }

    function withdrawDaoReserveInternal(uint withdrawTokens, uint64 chainId) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.withdrawDaoReserveAllowed(address(this), msg.sender, withdrawTokens);
        if (allowed != 0) {
            revert withdrawDaoReserveComptrollerRejection(allowed);
        }

        if (underlyingReserve[msg.sender] < withdrawTokens) {
            revert withdrawDaoReserveInsufficientBalance();
        }
        
        doTransferOut_Crosschain(payable(msg.sender), withdrawTokens, chainId);

        underlyingReserve[msg.sender] = sub_(underlyingReserve[msg.sender], withdrawTokens);

        emit WithdrawDaoReserve(msg.sender, withdrawTokens, underlyingReserve[msg.sender]);
    }
    
    function withdrawMemberReserveInternal(address dao, uint withdrawTokens, uint64 chainId) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.withdrawMemberReserveAllowed(address(this), dao, msg.sender, withdrawTokens);
        if (allowed != 0) {
            revert withdrawMemberReserveComptrollerRejection(allowed);
        }

        require(chainId != 0, "ChainId cannot be 0 for crosschain transfer");
        
        if (underlyingReserve[msg.sender] < withdrawTokens) {
            revert withdrawMemberReserveInsufficientBalance();
        }
        
        doTransferOut_Crosschain(payable(msg.sender), withdrawTokens, chainId);

        underlyingReserve[msg.sender] = sub_(underlyingReserve[msg.sender], withdrawTokens);

        emit WithdrawMemberReserve(msg.sender, withdrawTokens, underlyingReserve[msg.sender]);
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

        uint err;
        uint memberReserve;
        uint memberBorrow;
        (err, memberReserve) = comptroller.getAccountReserve(borrower);
        if(err != 0) {
            revert BorrowComptrollerRejection(err);
        }
        (err, memberBorrow) = comptroller.getAccountBorrow(borrower);
        if(err != 0) {
            revert BorrowComptrollerRejection(err);
        }

        uint memberCollateralRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getMemberCollateralRate(dao, borrower);
        uint memberGuaranteeCollateral = div_(memberBorrow, memberCollateralRateMantissa);
        uint totalGuaranteeCollateral = memberBorrow - memberGuaranteeCollateral;
        uint protocolToDaoGuaranteeRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getProtocolToDaoGuaranteeRate(dao);
        uint daoGuaranteeCollateral = div_(totalGuaranteeCollateral, add_(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), Exp({mantissa: mantissaOne})));
        uint protocolGuaranteeCollateral = mul_ScalarTruncate(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), daoGuaranteeCollateral);
        
        underlyingGuarantee[borrower] = add_(underlyingGuarantee[borrower], memberGuaranteeCollateral);
        underlyingGuarantee[dao] = add_(underlyingGuarantee[dao], daoGuaranteeCollateral);
        underlyingGuarantee[address(comptroller)] = add_(underlyingGuarantee[address(comptroller)], protocolGuaranteeCollateral);

        borrowContracts[borrower].push(borrowContract({
            principal: borrowAmount,
            memberCollateral: memberGuaranteeCollateral,
            daoCollateral: daoGuaranteeCollateral,
            protocolCollateral: protocolGuaranteeCollateral,
            interestIndex: borrowIndex,
            openTimestamp: block.timestamp,
            dueTimestamp: dueTimestamp
        }));

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

    /*
     * TODO: Add onlyOwner modifier
     */
    function registerAddress(uint64 chainId, address tokenPoolAddress) external {
        require(chainId != 0, "ChainId cannot be 0");
        require(chainIdToAddress[chainId] == address(0), "ChainId already registered");
        chainIdToAddress[chainId] = tokenPoolAddress;
    }
}