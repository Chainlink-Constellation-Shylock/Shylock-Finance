// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20Upgradeable } from "@openzeppelin-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";

interface ICToken is IERC20Upgradeable {
    function exchangeRateCurrent() external returns (uint256);
}
