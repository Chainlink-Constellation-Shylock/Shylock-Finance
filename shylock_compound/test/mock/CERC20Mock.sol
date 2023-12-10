// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../utils/CustomMath.sol";
import "./ERC20Mock.sol";
import { ERC20Upgradeable, IERC20Upgradeable } from "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import { ICERC20 } from "../interfaces/ICERC20.sol";

contract CERC20Mock is ERC20Upgradeable, ICERC20 {
    ERC20Mock public underlying_;

    bool public transferFromFail;
    bool public transferFail;

    bool public mintFail;
    bool public redeemUnderlyingFail;
    uint256 exchangeRateCurrentValue;

    function initialize(ERC20Mock _underlying) public initializer {
        ERC20Upgradeable.__ERC20_init("cDAI", "cUSD");
        underlying_ = _underlying;
        exchangeRateCurrentValue = 1;
    }

    function exchangeRateCurrent() public view returns (uint256) {
        return exchangeRateCurrentValue;
    }

    function mint(uint256 mintAmount) external returns (uint256) {
        if (mintFail) {
            return 1;
        }

        uint256 amountCTokens = CustomMath.divScalarByExpTruncate(mintAmount, exchangeRateCurrent());

        _mint(msg.sender, amountCTokens);

        underlying_.burn(msg.sender, mintAmount);

        return 0;
    }

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {
        if (redeemUnderlyingFail) {
            return 1;
        }

        uint256 amountCTokens = CustomMath.divScalarByExpTruncate(redeemAmount, exchangeRateCurrent());

        _burn(msg.sender, amountCTokens);

        underlying_.mint(msg.sender, redeemAmount);

        return 0;
    }

    // solhint-disable-next-line no-empty-blocks
    function redeem(uint256 redeemTokens) external returns (uint256) {}

    function setMintFail(bool _mintFail) external {
        mintFail = _mintFail;
    }

    function setRedeemUnderlyingFail(bool _redeemUnderlyingFail) external {
        redeemUnderlyingFail = _redeemUnderlyingFail;
    }

    function setExchangeRateCurrent(uint256 _exchangeRateCurrent) external {
        exchangeRateCurrentValue = _exchangeRateCurrent;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override(ERC20Upgradeable, IERC20Upgradeable) returns (bool) {
        if (transferFromFail) {
            return false;
        }

        return ERC20Upgradeable.transferFrom(from, to, amount);
    }

    function setTransferFromFail(bool fail) external {
        transferFromFail = fail;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override(ERC20Upgradeable, IERC20Upgradeable)
        returns (bool)
    {
        if (transferFail) {
            return false;
        }

        return ERC20Upgradeable.transfer(to, amount);
    }

    function setTransferFail(bool fail) external {
        transferFail = fail;
    }
}