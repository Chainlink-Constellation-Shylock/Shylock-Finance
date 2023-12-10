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


abstract contract ShylockCToken is CToken, ShylockCTokenInterface {
    function doTransferOut_Crosschain(address payable to, uint amount, uint64 chainId) virtual internal;
    
    function getAccountGuarantee(address account) public view returns (uint) {
        return shylockGuarantee[account].principal * borrowIndex / shylockGuarantee[account].interestIndex; 
    }

    function getBorrowContractdByIndex(address account, uint index) public returns (borrowContract memory) {
        // check the borrowContrac[index] is exist
        if(borrowContracts[account].length <= index){
            revert BrrowContracNotExist();
        }

        borrowContract memory borrowContract = borrowContracts[account][index];

        if (borrowContract.principal == 0) {
            revert BrrowContracNotExist();
        }

        uint newPrincipal = borrowContract.principal * borrowIndex / borrowContract.interestIndex;
        uint memberCollateralRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getMemberCollateralRate(borrowContract.dao, account);
        uint memberGuaranteeCollateral = div_(newPrincipal, memberCollateralRateMantissa);
        uint totalGuaranteeCollateral = newPrincipal - memberGuaranteeCollateral;
        uint protocolToDaoGuaranteeRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getProtocolToDaoGuaranteeRate(borrowContract.dao);
        uint daoGuaranteeCollateral = div_(totalGuaranteeCollateral, add_(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), Exp({mantissa: mantissaOne})));
        uint protocolGuaranteeCollateral = mul_ScalarTruncate(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), daoGuaranteeCollateral);
        memberGuaranteeCollateral = sub_(newPrincipal, add_(daoGuaranteeCollateral, protocolGuaranteeCollateral));

        borrowContract.principal = newPrincipal;
        borrowContract.memberCollateral = memberGuaranteeCollateral;
        borrowContract.daoCollateral = daoGuaranteeCollateral;
        borrowContract.protocolCollateral = protocolGuaranteeCollateral;

        return borrowContract;
    }

    function addDaoReserveInternal(uint reserveAmount, uint64 chainId) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.addDaoReserveAllowed(address(this), msg.sender, reserveAmount);
        if (allowed != 0) {
            revert AddDaoReserveComptrollerRejection(allowed);
        }

        uint actualReserveAmount;
        if(chainId == 0){
            actualReserveAmount = doTransferIn(msg.sender, reserveAmount);
        }
        else{
            actualReserveAmount = reserveAmount;
        }

        shylockReserve[msg.sender] = add_(shylockReserve[msg.sender], actualReserveAmount);
        totalShylockReserve = add_(totalShylockReserve, actualReserveAmount);

        emit AddDaoReserve(msg.sender, actualReserveAmount, shylockReserve[msg.sender]);

    }

    function addMemberReserveInternal(address dao, uint reserveAmount, uint64 chainId) internal nonReentrant {
        /* Fail if Member not allowed */
        uint allowed = comptroller.addMemberReserveAllowed(address(this), dao, msg.sender, reserveAmount);
        if (allowed != 0) {
            revert AddMemberReserveComptrollerRejection(allowed);
        }

        uint actualReserveAmount;
        if(chainId == 0){
            actualReserveAmount = doTransferIn(msg.sender, reserveAmount);
        }
        else{
            actualReserveAmount = reserveAmount;
        }

        shylockReserve[msg.sender] = add_(shylockReserve[msg.sender], actualReserveAmount);
        totalShylockReserve = add_(totalShylockReserve, actualReserveAmount);

        emit AddMemberReserve(msg.sender, actualReserveAmount, shylockReserve[msg.sender]);
    }

    function withdrawDaoReserveInternal(uint withdrawTokens, uint64 chainId) internal nonReentrant {
        /* Fail if Dao not allowed */
        uint allowed = comptroller.withdrawDaoReserveAllowed(address(this), msg.sender, withdrawTokens);
        if (allowed != 0) {
            revert WithdrawDaoReserveComptrollerRejection(allowed);
        }

        if (shylockReserve[msg.sender] < withdrawTokens) {
            revert WithdrawDaoReserveInsufficientBalance();
        }
        
        if(chainId == 0){
            doTransferOut(payable(msg.sender), withdrawTokens);
        }
        else{
            doTransferOut_Crosschain(payable(msg.sender), withdrawTokens, chainId);
        }

        shylockReserve[msg.sender] = sub_(shylockReserve[msg.sender], withdrawTokens);
        totalShylockReserve = sub_(totalShylockReserve, withdrawTokens);

        emit WithdrawDaoReserve(msg.sender, withdrawTokens, shylockReserve[msg.sender]);
    }
    
    function withdrawMemberReserveInternal(address dao, uint withdrawTokens, uint64 chainId) internal nonReentrant {
        /* Fail if Member not allowed */
        uint allowed = comptroller.withdrawMemberReserveAllowed(address(this), dao, msg.sender, withdrawTokens);
        if (allowed != 0) {
            revert WithdrawMemberReserveComptrollerRejection(allowed);
        }
        
        if (shylockReserve[msg.sender] < withdrawTokens) {
            revert WithdrawMemberReserveInsufficientBalance();
        }
        
        if(chainId==0){
            doTransferOut(payable(msg.sender), withdrawTokens);
        }
        else{
            doTransferOut_Crosschain(payable(msg.sender), withdrawTokens, chainId);
        }

        shylockReserve[msg.sender] = sub_(shylockReserve[msg.sender], withdrawTokens);
        totalShylockReserve = sub_(totalShylockReserve, withdrawTokens);

        emit WithdrawMemberReserve(msg.sender, withdrawTokens, shylockReserve[msg.sender]);
    }

    function borrowInternal(address dao, uint dueTimestamp, uint borrowAmount, uint64 chainId) internal nonReentrant {
        accrueInterest();
        // borrowFresh emits borrow-specific logs on errors, so we don't need to
        borrowFresh(dao, payable(msg.sender), dueTimestamp, borrowAmount, chainId);
    }

    function borrowFresh(address dao, address payable borrower, uint dueTimestamp, uint borrowAmount, uint64 chainId) internal {
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

        
        uint memberCollateralRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getMemberCollateralRate(dao, borrower);
        uint memberGuaranteeCollateral = div_(borrowAmount, memberCollateralRateMantissa);
        uint totalGuaranteeCollateral = borrowAmount - memberGuaranteeCollateral;
        uint protocolToDaoGuaranteeRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getProtocolToDaoGuaranteeRate(dao);
        uint daoGuaranteeCollateral = div_(totalGuaranteeCollateral, add_(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), Exp({mantissa: mantissaOne})));
        uint protocolGuaranteeCollateral = mul_ScalarTruncate(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), daoGuaranteeCollateral);
        uint actualBorrowAmount = memberGuaranteeCollateral + daoGuaranteeCollateral + protocolGuaranteeCollateral;
        
        shylockGuarantee[borrower].principal = getAccountGuarantee(borrower) + memberGuaranteeCollateral;
        shylockGuarantee[borrower].interestIndex = borrowIndex;
        shylockGuarantee[dao].principal = getAccountGuarantee(dao) + daoGuaranteeCollateral;
        shylockGuarantee[dao].interestIndex = borrowIndex;
        shylockGuarantee[address(comptroller)].principal = getAccountGuarantee(address(comptroller)) + protocolGuaranteeCollateral;
        shylockGuarantee[address(comptroller)].interestIndex = borrowIndex;

        borrowContracts[borrower].push(borrowContract({
            dao : dao,
            principal: actualBorrowAmount,
            memberCollateral: memberGuaranteeCollateral,
            daoCollateral: daoGuaranteeCollateral,
            protocolCollateral: protocolGuaranteeCollateral,
            interestIndex: borrowIndex,
            openTimestamp: block.timestamp,
            dueTimestamp: dueTimestamp
        }));

        uint accountBorrowsPrev = borrowBalanceStoredInternal(borrower);

        accountBorrows[borrower].principal = accountBorrowsPrev + actualBorrowAmount;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrows + actualBorrowAmount;


        if(chainId == 0){
            doTransferOut(borrower, actualBorrowAmount);
        }
        else{
            doTransferOut_Crosschain(borrower, actualBorrowAmount, chainId);
        }

        /* We emit a Borrow event */
        emit Borrow(borrower, actualBorrowAmount, accountBorrowsPrev + actualBorrowAmount, totalBorrows + actualBorrowAmount);
    }


    function repayBorrowInternal(address dao, uint repayAmount, uint index, uint64 chainId) internal nonReentrant {
        accrueInterest();
        // repayBorrowFresh emits repay-borrow-specific logs on errors, so we don't need to
        repayBorrowFresh(msg.sender, dao, msg.sender, repayAmount, index, chainId);
    }

    function repayBorrowFresh(address payer, address dao, address borrower, uint repayAmount, uint index, uint64 chainId) internal returns (uint) {
        /* Fail if repayBorrow not allowed */
        uint allowed = comptroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        if (allowed != 0) {
            revert RepayBorrowComptrollerRejection(allowed);
        }

        /* Verify market's block number equals current block number */
        if (accrualBlockNumber != getBlockNumber()) {
            revert RepayBorrowFreshnessCheck();
        }

        /* We fetch the amount the borrower owes, with accumulated interest */
        uint accountBorrowsPrev = borrowBalanceStoredInternal(borrower);

        /* If repayAmount == -1, repayAmount = accountBorrows */
        uint repayAmountFinal = repayAmount == type(uint).max ? accountBorrowsPrev : repayAmount;

        uint actualRepayAmount;
        if(chainId == 0){
            actualRepayAmount = doTransferIn(payer, repayAmountFinal);
        }
        else{
            actualRepayAmount = repayAmountFinal;
        }

        uint memberCollateralRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getMemberCollateralRate(dao, borrower);
        uint memberGuaranteeCollateral = div_(actualRepayAmount, memberCollateralRateMantissa);
        uint totalGuaranteeCollateral = actualRepayAmount - memberGuaranteeCollateral;
        uint protocolToDaoGuaranteeRateMantissa = ShylockComptrollerStorage(address(comptroller)).governanceContract().getProtocolToDaoGuaranteeRate(dao);
        uint daoGuaranteeCollateral = div_(totalGuaranteeCollateral, add_(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), Exp({mantissa: mantissaOne})));
        uint protocolGuaranteeCollateral = mul_ScalarTruncate(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), daoGuaranteeCollateral);
        memberGuaranteeCollateral = actualRepayAmount - daoGuaranteeCollateral - protocolGuaranteeCollateral;

        shylockGuarantee[borrower].principal = getAccountGuarantee(borrower) - memberGuaranteeCollateral;
        shylockGuarantee[borrower].interestIndex = borrowIndex;
        shylockGuarantee[dao].principal = getAccountGuarantee(dao) - daoGuaranteeCollateral;
        shylockGuarantee[dao].interestIndex = borrowIndex;
        shylockGuarantee[address(comptroller)].principal = getAccountGuarantee(address(comptroller)) - protocolGuaranteeCollateral;
        shylockGuarantee[address(comptroller)].interestIndex = borrowIndex;

        borrowContract memory nextBorrowContract = getBorrowContractdByIndex(borrower, index);

        borrowContract storage prevBorrowContract = borrowContracts[borrower][index];
        prevBorrowContract.principal = nextBorrowContract.principal- actualRepayAmount;
        prevBorrowContract.memberCollateral = nextBorrowContract.memberCollateral - memberGuaranteeCollateral;
        prevBorrowContract.daoCollateral = nextBorrowContract.daoCollateral - daoGuaranteeCollateral;
        prevBorrowContract.protocolCollateral = nextBorrowContract.protocolCollateral - protocolGuaranteeCollateral;
        prevBorrowContract.interestIndex = borrowIndex;

        if(prevBorrowContract.principal == 0 && prevBorrowContract.memberCollateral == 0 && prevBorrowContract.daoCollateral == 0 && prevBorrowContract.protocolCollateral == 0){
            uint len = borrowContracts[borrower].length;
            borrowContracts[borrower][index] = borrowContracts[borrower][len - 1];
            borrowContracts[borrower].pop();
        }

        /* We write the previously calculated values into storage */
        accountBorrows[borrower].principal = accountBorrowsPrev - actualRepayAmount;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrows - actualRepayAmount;

        /* We emit a RepayBorrow event */
        emit RepayBorrow(payer, borrower, actualRepayAmount, accountBorrowsPrev - actualRepayAmount, totalBorrows - actualRepayAmount);

        return actualRepayAmount;
    }

}