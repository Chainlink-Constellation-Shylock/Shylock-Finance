// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

abstract contract ShylockGovernanceInterface {
    function getDaoCap(address dao) virtual external returns (uint);

}