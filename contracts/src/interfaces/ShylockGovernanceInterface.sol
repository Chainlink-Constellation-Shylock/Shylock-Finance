// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

abstract contract ShylockGovernanceInterface {
    struct DaoDataInfo {
        uint[] weights;         // scale of % - e.g. 96 equals 96%
        address[] dataOrigins; // addresses of FunctionsConsumer contract
    }

    uint constant WEIGHT_DENOM = 100;
    uint public constant MANTISSA = 1e18;


    mapping(address => DaoDataInfo) DaoDataInfos;
    mapping(address => string) daoNames;
    mapping(address => uint) daoCap;
    mapping(address => uint) protocolToDaoGuaranteeRate;
    mapping(address => uint) memberCap;
    mapping(address => uint) memberGuaranteeRate;

    error InvalidLength();
    error InvalidExecutor();
    error InvalidOwner();

    function getDaoCap(address dao) virtual external returns (uint);
    function getProtocolToDaoGuaranteeRate(address dao) virtual external returns (uint);
    function getMemberCap(address dao, address member) virtual external returns (uint);
    function getMemberCollateralRate(address member) virtual external returns (uint);

}