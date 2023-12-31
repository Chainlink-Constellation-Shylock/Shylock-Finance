// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;

abstract contract ShylockGovernanceInterface {
    function getDaoCap(address dao) virtual external returns (uint);
    function getProtocolToDaoGuaranteeRate(address dao) virtual external returns (uint);
    function getMemberCap(address dao, address member) virtual external returns (uint);
    function getMemberCollateralRate(address dao, address member) virtual external returns (uint);

}