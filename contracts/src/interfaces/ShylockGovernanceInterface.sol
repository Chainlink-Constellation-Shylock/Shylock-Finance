// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

abstract contract ShylockGovernanceInterface {
    /**
     * @param weights - scale of % - e.g. 96 equals 96%
     * @param dataOrigins - addresses of FunctionsConsumer contract
     * @param daoName - name of DAO
     * @param tierThreshold - tier threshold restricting users who can get opportunity to lend
     * @param numberOfTiers - number of tiers that DAO has
     * @param daoCap - total cap of DAO
     * @param daoReputationCap - reputation cap of DAO
     * @param protocolToDaoGuaranteeRate - rate of protocol to DAO guarantee
     * @param reputation - reputation of DAO
     */
    struct DaoInfo {
        string daoName;
        uint tierThreshold;     // tier threshold restricting users who can get opportunity to lend
        uint numberOfTiers;     // number of tiers that DAO has
        uint daoCap;
        uint protocolToDaoGuaranteeRate;
        uint reputation;
        uint[] weights;         // scale of % - e.g. 96 equals 96%
        address[] dataOrigins;  // addresses of FunctionsConsumer contract
    }

    /**
     * @param memberReputation - reputation of member
     * @param isEnrolled - whether member have used our protocol or not
     */
    struct MemberInfo {
        uint memberReputation;
        bool isEnrolled;
    }

    uint public constant WEIGHT_DENOM = 100;
    uint public constant MANTISSA = 1e18;
    uint public constant CHAINLINK_ORACLE_DENOM = 1e8;


    mapping(address dao => DaoInfo) public daoInfos;
    mapping(address member => MemberInfo) memberInfos;

    error InvalidLength();
    error InvalidWeights();
    error InvalidExecutor();
    error InvalidAddress();

    function getDaoCap(address dao) virtual external returns (uint);
    function getProtocolToDaoGuaranteeRate(address dao) virtual external returns (uint);
    function getMemberCap(address dao, address member) virtual external returns (uint);
    function getMemberCollateralRate(address dao, address member) virtual external returns (uint);
}