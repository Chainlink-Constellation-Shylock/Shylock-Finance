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

    function addToReserveInternal(CToken cToken, address target) internal returns (Error) {
        Market storage marketToJoin = markets[address(cToken)];

        if (!marketToJoin.isListed) {
            // market is not listed, cannot join
            return Error.MARKET_NOT_LISTED;
        }

        if (marketToJoin.accountMembership[target] == true) {
            // already joined
            return Error.NO_ERROR;
        }

        // survived the gauntlet, add to list
        // NOTE: we store these somewhat redundantly as a significant optimization
        //  this avoids having to iterate through the list for the most common use cases
        //  that is, only when we need to perform liquidity checks
        //  and not whenever we want to check if an account is in a particular market
        marketToJoin.accountMembership[target] = true;
        accountReserves[target].push(cToken);

        emit MarketEntered(cToken, target);

        return Error.NO_ERROR;
    }


    function addDaoReserveAllowed(address cToken, address dao, uint reserveAmount) override external governanceContractInitialized returns (uint) {
        if (!markets[cToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        // check dao is registered

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

        uint daoReserve;

        // For each reserve the account is in
        ShylockCToken[] memory assets = accountReserves[dao];
        for (uint i = 0; i < assets.length; i++) {
            ShylockCToken assets = assets[i];
            uint assetReserve = assets.underlyingReserves(dao);
            uint oraclePriceMantissa = assets.oraclePriceMantissa();
            if (oraclePriceMantissa == 0) {
                return (Error.PRICE_ERROR, 0, 0);
            }
            uint oraclePrice = Exp({mantissa: oraclePriceMantissa});
            daoReserve = mul_ScalarTruncateAddUInt(oraclePrice, assetReserve, daoReserve);
        }

        if (daoCap < daoReserve + reserveAmount) {
            return uint(Error.DAO_CAP_EXCEEDED);
        }

        return uint(Error.NO_ERROR);
    }

}