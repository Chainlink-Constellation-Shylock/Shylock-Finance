// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;

import "./compound/Comptroller.sol";
import "./interfaces/ShylockComptrollerStorage.sol";
import "./interfaces/ShylockComptrollerInterface.sol";

/**
 * @title Shylock Finance's Comptroller Contract
 * @author Shylock Fincance
 */
 
contract ShylockComptroller is Comptroller, ShylockComptrollerInterface, ShylockComptrollerStorage{
    /// @notice Emitted when an account enters a market
    event ReserveEntered(CToken cToken, address account);

    modifier governanceContractInitialized() {
        require(address(governanceContract) != address(0), "governance contract not initialized");
        _;
    }

    function setGovernanceContract(ShylockGovernanceInterface _governanceContract) override external {
        require(msg.sender == admin, "only admin can set governance contract");
        governanceContract = _governanceContract;
    }

    function getAllAccountCtokenBalance(address account) override external view returns (uint, uint) {
        uint totalBalance;
        uint assetBalance;
        uint oraclePriceMantissa;
        Exp memory oraclePrice;

        // For each reserve the account is in
        ShylockCToken[] memory assets = accountReserves[account];
        for (uint i = 0; i < assets.length; i++) {
            ShylockCToken asset = assets[i];
            oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (oraclePriceMantissa == 0) {
                return (uint(Error.PRICE_ERROR), 0);
            }
            oraclePrice = Exp({mantissa: oraclePriceMantissa});
            assetBalance = asset.balanceOfUnderlyingNoGas(account);
            totalBalance = mul_ScalarTruncateAddUInt(oraclePrice, assetBalance, totalBalance);
        }
        
        return (uint(Error.NO_ERROR), totalBalance);
    }

    function getAllAccountReserve(address account) override public view returns (uint, uint) {
        uint totalReserve;
        uint assetReserve;
        uint oraclePriceMantissa;
        Exp memory oraclePrice;

        // For each reserve the account is in
        ShylockCToken[] memory assets = accountReserves[account];
        for (uint i = 0; i < assets.length; i++) {
            ShylockCToken asset = assets[i];
            oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (oraclePriceMantissa == 0) {
                return (uint(Error.PRICE_ERROR), 0);
            }
            oraclePrice = Exp({mantissa: oraclePriceMantissa});
            assetReserve = asset.shylockReserve(account);
            totalReserve = mul_ScalarTruncateAddUInt(oraclePrice, assetReserve, totalReserve);
        }

        return (uint(Error.NO_ERROR), totalReserve);
    }

    function getAllAccountGuarantee(address account) public view returns (uint, uint) {
        uint totalGuarantee;
        uint assetGuarantee;
        uint oraclePriceMantissa;
        Exp memory oraclePrice;

        // For each reserve the account is in
        ShylockCToken[] memory assets = accountReserves[account];
        for (uint i = 0; i < assets.length; i++) {
            ShylockCToken asset = assets[i];
            oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (oraclePriceMantissa == 0) {
                return (uint(Error.PRICE_ERROR), 0);
            }
            oraclePrice = Exp({mantissa: oraclePriceMantissa});
            assetGuarantee = asset.getAccountGuarantee(account);
            totalGuarantee = mul_ScalarTruncateAddUInt(oraclePrice, assetGuarantee, totalGuarantee);
        }

        return (uint(Error.NO_ERROR), totalGuarantee);
    }

    function getAllAccountBorrow(address account) override public view returns (uint, uint) {
        AccountLiquidityLocalVars memory vars; // Holds all our calculation results
        uint oErr;
        uint totalBorrow;

        // For each asset the account is in
        CToken[] memory assets = accountAssets[account];
        for (uint i = 0; i < assets.length; i++) {
            CToken asset = assets[i];

            // Read the balances and exchange rate from the cToken
            (oErr, , vars.borrowBalance, ) = asset.getAccountSnapshot(account);
            if (oErr != 0) { // semi-opaque error code, we assume NO_ERROR == 0 is invariant between upgrades
                return (uint(Error.SNAPSHOT_ERROR), 0);
            }

            // Get the normalized price of the asset
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (vars.oraclePriceMantissa == 0) {
                return (uint(Error.PRICE_ERROR), 0);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

            totalBorrow = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, totalBorrow);
        }

        return (uint(Error.NO_ERROR), totalBorrow);
    }


    function addToReserveInternal(ShylockCToken cToken, address account) internal returns (Error) {
        Market storage marketToJoin = markets[address(cToken)];

        if (!marketToJoin.isListed) {
            // market is not listed, cannot join
            return Error.MARKET_NOT_LISTED;
        }

        if (marketToJoin.accountMembership[account] == true) {
            // already joined
            return Error.NO_ERROR;
        }

        // survived the gauntlet, add to list
        // NOTE: we store these somewhat redundantly as a significant optimization
        //  this avoids having to iterate through the list for the most common use cases
        //  that is, only when we need to perform liquidity checks
        //  and not whenever we want to check if an account is in a particular market
        marketToJoin.accountMembership[account] = true;
        accountReserves[account].push(cToken);

        emit ReserveEntered(cToken, account);

        return Error.NO_ERROR;
    }


    function addDaoReserveAllowed(address cToken, address dao, uint reserveAmount) override external returns (uint) {
        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        if (!markets[cToken].accountMembership[dao]) {
            // only cTokens may call borrowAllowed if borrower not in market
            require(msg.sender == cToken, "sender must be cToken");

            // attempt to add borrower to the market
            Error err = addToReserveInternal(ShylockCToken(msg.sender), dao);
            if (err != Error.NO_ERROR) {
                return uint(err);
            }

            // it should be impossible to break the important invariant
            assert(markets[cToken].accountMembership[dao]);
        }
        
        // check the dao is registered by checking the dao's cap
        uint daoCap = governanceContract.getDaoCap(dao);
        if (daoCap == 0) {
            return uint(Error.DAO_NOT_REGISTERED);
        }

        uint err;
        uint daoReserve;
        // uint daoGuarantee;
        (err, daoReserve) = getAllAccountReserve(dao);
        if (err != uint(Error.NO_ERROR)) {
            return uint(err);
        }
        // (err, daoGuarantee) = getAccountGuarantee(dao);
        // if (err != uint(Error.NO_ERROR)) {
        //     return uint(err);
        // }

        if (daoCap < daoReserve + reserveAmount) { //+ daoGuarantee ) {
            return uint(Error.DAO_CAP_EXCEEDED);
        }

        return uint(Error.NO_ERROR);
    }

    function addMemberReserveAllowed(address cToken, address dao, address member, uint reserveAmount) override external governanceContractInitialized returns (uint) {
        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        // check member is registered by checking the member's cap
        uint memberCap = governanceContract.getMemberCap(dao, member);
        if (memberCap == 0) {
            return uint(Error.NOT_DAO_MEMBER);
        }

        if (!markets[cToken].accountMembership[member]) {
            // only cTokens may call borrowAllowed if borrower not in market
            require(msg.sender == cToken, "sender must be cToken");

            // attempt to add borrower to the market
            Error err = addToReserveInternal(ShylockCToken(msg.sender), member);
            if (err != Error.NO_ERROR) {
                return uint(err);
            }

            // it should be impossible to break the important invariant
            assert(markets[cToken].accountMembership[member]);
        }
        
        // uint memberReserve = getAccountReserves(member);

        // if (memberCap < memberReserve + reserveAmount) {
        //     return uint(Error.MEMBER_CAP_EXCEEDED);
        // }

        return uint(Error.NO_ERROR);
    }

    function withdrawDaoReserveAllowed(address cToken, address dao, uint withdrawTokens) override external returns (uint) {
        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        if (!markets[cToken].accountMembership[dao]) {
            return uint(Error.NO_ERROR);
        }

        // check the dao is registered by checking the dao's cap
        uint daoCap = governanceContract.getDaoCap(dao);
        if (daoCap == 0) {
            return uint(Error.DAO_NOT_REGISTERED);
        }

        uint err;
        uint daoReserve;
        (err, daoReserve) = getAllAccountReserve(dao);
        if (err != uint(Error.NO_ERROR)) {
            return uint(err);
        }
        uint daoGuarantee;
        (err, daoGuarantee) = getAllAccountGuarantee(dao);
        if (err != uint(Error.NO_ERROR)) {
            return uint(err);
        }
        uint daoAvailableReserve = daoReserve - daoGuarantee;

        uint oraclePriceMantissa = oracle.getUnderlyingPrice(ShylockCToken(cToken));
        if (oraclePriceMantissa == 0) {
            return (uint(Error.PRICE_ERROR));
        }
        Exp memory oraclePrice = Exp({mantissa: oraclePriceMantissa});
        uint withdrawAmount = mul_ScalarTruncate(oraclePrice, withdrawTokens);

        if (daoAvailableReserve < withdrawAmount) {
            return uint(Error.INSUFFICIENT_LIQUIDITY);
        }

        return uint(Error.NO_ERROR);
    }

    function withdrawMemberReserveAllowed(address cToken, address dao, address member, uint withdrawTokens) override external returns (uint) {
        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        if (!markets[cToken].accountMembership[member]) {
            return uint(Error.NO_ERROR);
        }

        (Error err, , uint shortfall) = getHypotheticalAccountReserveInternal(dao, member, CToken(cToken), withdrawTokens, 0);
        if (err != Error.NO_ERROR) {
            return uint(err);
        }
        if (shortfall > 0) {
            return uint(Error.INSUFFICIENT_LIQUIDITY);
        }

        return uint(Error.NO_ERROR);
    }

    function borrowAllowed(address cToken, address dao, address borrower, uint borrowAmount) override external returns (uint) {
        // Pausing is a very serious situation - we revert to sound the alarms
        require(!borrowGuardianPaused[cToken], "borrow is paused");

        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        if (!markets[cToken].accountMembership[borrower]) {
            // only cTokens may call borrowAllowed if borrower not in market
            require(msg.sender == cToken, "sender must be cToken");

            // attempt to add borrower to the market
            Error err = addToMarketInternal(CToken(msg.sender), borrower);
            if (err != Error.NO_ERROR) {
                return uint(err);
            }

            // it should be impossible to break the important invariant
            assert(markets[cToken].accountMembership[borrower]);
        }

        if (oracle.getUnderlyingPrice(CToken(cToken)) == 0) {
            return uint(Error.PRICE_ERROR);
        }

        // check the member is dao member by checking the member's cap
        uint memberCap = governanceContract.getMemberCap(dao, borrower);
        if (memberCap == 0) {
            return uint(Error.NOT_DAO_MEMBER);
        }

        uint borrowCap = borrowCaps[cToken];
        // Borrow cap of 0 corresponds to unlimited borrowing
        if (borrowCap != 0) {
            uint totalBorrows = CToken(cToken).totalBorrows();
            uint nextTotalBorrows = totalBorrows + borrowAmount;
            require(nextTotalBorrows < borrowCap, "market borrow cap reached");
        }

        (Error err, , uint shortfall) = getHypotheticalAccountReserveInternal(dao, borrower, CToken(cToken), 0, borrowAmount);
        if (err != Error.NO_ERROR) {
            return uint(err);
        }
        if (shortfall > 0) {
            return uint(Error.INSUFFICIENT_LIQUIDITY);
        }

        return uint(Error.NO_ERROR);
    }


    function getHypotheticalAccountLiquidityInternal(
        address account,
        CToken cTokenModify,
        uint redeemTokens,
        uint borrowAmount) override internal view returns (Error, uint, uint) {

        AccountLiquidityLocalVars memory vars; // Holds all our calculation results
        uint oErr;

        // For each asset the account is in
        CToken[] memory assets = accountAssets[account];
        for (uint i = 0; i < assets.length; i++) {
            CToken asset = assets[i];

            // Read the balances and exchange rate from the cToken
            (oErr, vars.cTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(account);
            if (oErr != 0) { // semi-opaque error code, we assume NO_ERROR == 0 is invariant between upgrades
                return (Error.SNAPSHOT_ERROR, 0, 0);
            }
            vars.collateralFactor = Exp({mantissa: markets[address(asset)].collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});

            // Get the normalized price of the asset
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (vars.oraclePriceMantissa == 0) {
                return (Error.PRICE_ERROR, 0, 0);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

            // Pre-compute a conversion factor from tokens -> ether (normalized price value)
            vars.tokensToDenom = mul_(mul_(vars.collateralFactor, vars.exchangeRate), vars.oraclePrice);

            // sumCollateral += tokensToDenom * cTokenBalance
            vars.sumCollateral = mul_ScalarTruncateAddUInt(vars.tokensToDenom, vars.cTokenBalance, vars.sumCollateral);

            // // sumBorrowPlusEffects += oraclePrice * borrowBalance
            // vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, vars.sumBorrowPlusEffects);

            // Calculate effects of interacting with cTokenModify
            if (asset == cTokenModify) {
                // redeem effect
                // sumBorrowPlusEffects += tokensToDenom * redeemTokens
                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.tokensToDenom, redeemTokens, vars.sumBorrowPlusEffects);

                // // borrow effect
                // // sumBorrowPlusEffects += oraclePrice * borrowAmount
                // vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, vars.sumBorrowPlusEffects);
            }
        }

        // These are safe, as the underflow condition is checked first
        if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
            return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
        } else {
            return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
        }
    }


    function getHypotheticalAccountReserveInternal(
        address dao,
        address account,
        CToken cTokenModify,
        uint withdrawTokens,
        uint borrowAmount) internal governanceContractInitialized returns (Error, uint, uint) {

        uint err;

        uint daoReserve;
        uint daoGuarantee;
        uint memberReserve;
        uint memberBorrow;
        (err, daoReserve) = getAllAccountReserve(dao); // 5
        if (err != uint(Error.NO_ERROR)) {
            return (Error(err), 0, 0);
        }
        
        (err, daoGuarantee) = getAllAccountGuarantee(dao); // 2
        if (err != uint(Error.NO_ERROR)) {
            return (Error(err), 0, 0);
        }
        
        (err, memberReserve) = getAllAccountReserve(account); // 20
        if (err != uint(Error.NO_ERROR)) {
            return (Error(err), 0, 0);
        }
        
        (err, memberBorrow) = getAllAccountBorrow(account); // 10
        if (err != uint(Error.NO_ERROR)) {
            return (Error(err), 0, 0);
        }
        
        uint oraclePriceMantissa = oracle.getUnderlyingPrice(cTokenModify);
        if (oraclePriceMantissa == 0) {
            return (Error.PRICE_ERROR, 0, 0);
        }
        // Calculate effects of interacting with cTokenModify
        memberBorrow = mul_ScalarTruncateAddUInt(Exp({mantissa: oraclePriceMantissa}), borrowAmount+withdrawTokens, memberBorrow); // 10 + 16 = 26

        // uint memberCap = governanceContract.getMemberCap(dao, account); // member's cap : 30
        // uint memberCollateralRateMantissa = governanceContract.getMemberCollateralRate(dao, account); // 180%, actually 1.8e18
        // uint protocolToDaoGuaranteeRateMantissa = governanceContract.getProtocolToDaoGuaranteeRate(dao); // if dao : protocol 1 : 2 it is 2e18
        uint memberCap = 30e18;
        uint memberCollateralRateMantissa = 18e17;
        uint protocolToDaoGuaranteeRateMantissa = 2e18;
        uint memberReserveBorrowable = mul_ScalarTruncate(Exp({mantissa: memberCollateralRateMantissa}), memberReserve); // 20 * 180% = 36
        uint exceedCollateral = memberReserveBorrowable - memberReserve; // 36 - 20 = 16
        if (exceedCollateral > memberCap) {
            exceedCollateral = memberCap;
        }
        uint daoGuaranteeCollateral = div_(exceedCollateral, add_(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), Exp({mantissa: mantissaOne}))); // 16 / 3 = 5
        if (daoGuaranteeCollateral > daoReserve - daoGuarantee) { // 5 > 3
            daoGuaranteeCollateral = daoReserve - daoGuarantee; // 3
        }
        // totalGuaranteeCollateral = daoGuranteeCollatera * ( 1 + protocolToDaoGuaranteeRateMantissa)
        uint totalGuaranteeCollateral =   mul_ScalarTruncateAddUInt(Exp({mantissa: protocolToDaoGuaranteeRateMantissa}), daoGuaranteeCollateral, daoGuaranteeCollateral); // 3 * ( 1 + 2 ) = 9

        if (totalGuaranteeCollateral + memberReserve > memberBorrow){ // 9 + 20 > 10 + 16
            return (Error.NO_ERROR, totalGuaranteeCollateral + memberReserve - memberBorrow, 0);
        } else {
            return (Error.NO_ERROR, 0, memberBorrow - totalGuaranteeCollateral - memberReserve);
        }
    }

}