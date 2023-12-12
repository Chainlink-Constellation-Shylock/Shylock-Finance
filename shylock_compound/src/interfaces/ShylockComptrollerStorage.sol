// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;

import "../ShylockCToken.sol";
import "./ShylockGovernanceInterface.sol";

abstract contract ShylockComptrollerStorage {
    ShylockGovernanceInterface public governanceContract;

    mapping (address => ShylockCToken[]) public accountReserves; 
}
