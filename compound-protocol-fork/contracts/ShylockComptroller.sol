// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./Comptroller.sol";
import "./ShylockComptrollerStorage.sol";
import "./ShylockComptrollerInterface.sol";

/**
 * @title Shylock Finance's Comptroller Contract
 * @author Shylock Fincance
 */
contract ShylockComptroller is Comptroller, ShylockComptrollerInterface, ShylockComptrollerStorage{

    modifier governanceContractInitialized() {
        require(address(governanceContract) != address(0), "governance contract not initialized");
        _;
    }

    function setGovernanceContract(ShylockGovernanceInterface _governanceContract) external {
        require(msg.sender == admin, "only admin can set governance contract");
        governanceContract = _governanceContract;
    }

    function getAccountReserves(address account) public view returns (uint) {
        uint totalReserve;
        uint assetReserve;
        uint oraclePriceMantissa;

        // For each reserve the account is in
        ShylockCToken[] memory assets = accountReserves[account];
        for (uint i = 0; i < assets.length; i++) {
            ShylockCToken asset = assets[i];
            assetReserve = asset.underlyingReserves(account);
            oraclePriceMantissa = assets.oraclePriceMantissa();
            if (oraclePriceMantissa == 0) {
                return (Error.PRICE_ERROR, 0, 0);
            }
            uint oraclePrice = Exp({mantissa: oraclePriceMantissa});
            totalReserve = mul_ScalarTruncateAddUInt(oraclePrice, assetReserve, totalReserve);
        }

        return totalReserve;
    }

    function addToReserveInternal(CToken cToken, address account) internal returns (Error) {
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

        emit MarketEntered(cToken, account);

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
            Error err = addToMarketInternal(CToken(msg.sender), dao);
            if (err != Error.NO_ERROR) {
                return uint(err);
            }

            // it should be impossible to break the important invariant
            assert(markets[cToken].accountMembership[dao]);
        }
        
        // check the amount not excceeds the dao's cap
        uint daoCap = governanceContract.getDaoCap(dao);
        if (daoCap == 0) {
            return uint(Error.DAO_NOT_REGISTERED);
        }

        uint daoReserve = getAccountReserves(dao);

        if (daoCap < daoReserve + reserveAmount) {
            return uint(Error.DAO_CAP_EXCEEDED);
        }

        return uint(Error.NO_ERROR);
    }

    function addMemberReserveAllowed(address cToken, address member, uint reserveAmount) override external governanceContractInitialized returns (uint) {
        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        // check member is registered by checking the member's cap
        uint memberCap = governanceContract.getMemberCap(member);
        if (memberCap == 0) {
            return uint(Error.NOT_DAO_MEMBER);
        }

        if (!markets[cToken].accountMembership[member]) {
            // only cTokens may call borrowAllowed if borrower not in market
            require(msg.sender == cToken, "sender must be cToken");

            // attempt to add borrower to the market
            Error err = addToMarketInternal(CToken(msg.sender), member);
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

    function getHypotheticalAccountLiquidityInternal(
        address account,
        CToken cTokenModify,
        uint redeemTokens,
        uint borrowAmount) override internal view governanceContractInitialized returns (Error, uint, uint) {

        AccountLiquidityLocalVars memory vars; // Holds all our calculation results
        uint oErr;

        uint memberReserve = getAccountReserves(account);
        uint memberCap = governanceContract.getMemberCap(account);
        uint memberGuaranteeRate = governanceContract.getMemberGuaranteeRate(account);
        uint protocolGuaranteeRate = governanceContract.getProtoclGuaranteeRate(account);
        uint memberBorrow;

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

            // sumBorrowPlusEffects += oraclePrice * borrowBalance
            // vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, vars.sumBorrowPlusEffects);
            memberBorrow = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, memberBorrow);

            // Calculate effects of interacting with cTokenModify
            if (asset == cTokenModify) {
                // redeem effect
                // sumBorrowPlusEffects += tokensToDenom * redeemTokens
                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.tokensToDenom, redeemTokens, vars.sumBorrowPlusEffects);

                // borrow effect
                // sumBorrowPlusEffects += oraclePrice * borrowAmount
                // vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, vars.sumBorrowPlusEffects);
                memberBorrow = mul_ScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, memberBorrow);
            }
        }

        // These are safe, as the underflow condition is checked first
        if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
            return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
        } else {
            return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
        }

        uint 


    }

}