// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import { ShylockGovernanceInterface } from "./interfaces/ShylockGovernanceInterface.sol";
import { ShylockGovernanceVote } from "./ShylockGovernanceVote.sol";
import { IFunctionsConsumer } from "./interfaces/IFunctionsConsumer.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract ShylockGovernance is ShylockGovernanceInterface, ShylockGovernanceVote {
    using Math for uint;

    address public owner;

    constructor(
        address _owner,
        address _comptroller
    ) ShylockGovernanceVote("Shylock", _comptroller) {
        owner = _owner;
    }

    /* Getter Functions for basic info */

    /** Function to get the DAO's data origin addresses and their weights
     * @param dao The address of the DAO
     * @return The addresses of the DAO's data origins
     * @return The weights of the DAO's data origins
     */
    function getDaoDataInfo(address dao) external view returns (uint[] memory, address[] memory) {
        return (daoInfos[dao].weights, daoInfos[dao].dataOrigins);
    }

    /** Function to get the DAO's cap
     * @param dao The address of the DAO
     * @return The cap of the DAO
     */
    function getDaoCap(address dao) override external view returns (uint) {
        return daoInfos[dao].daoCap;
    }

    /** Function to get the protocol to DAO guarantee rate
     * @dev The ratio of the protocol's guarantee to the DAO's guarantee in mantissa scale
     * @param dao The address of the DAO
     * @return The ratio of the protocol's guarantee to the DAO's guarantee in mantissa scale
     */  
    function getProtocolToDaoGuaranteeRate(address dao) override external view returns (uint) {
        return daoInfos[dao].protocolToDaoGuaranteeRate;
    }

    /** Function to get the member's cap
     * @param dao The address of the DAO
     * @param member The address of the member
     * @return The cap of the member
     */
    function getMemberCap(address dao, address member) override external returns (uint) {
        return calculateMemberCap(dao, member);
    }

    /** Function to get the member's collateral rate in mantissa scale
     * @dev If it is 180 * 1e18, the ratio he can get is 180%
     * @param dao The address of the DAO
     * @param member The address of the member
     * @return The collateral rate of the member
     */
    function getMemberCollateralRate(address dao, address member) override view external returns (uint) {
        return memberCollateralRate[dao][member];
    }

    /** Function to get the DAO's reputation
     * @param dao The address of the DAO
     * @return The reputation of the DAO
     */
    function getDaoReputation(address dao) external view returns (uint) {
        return daoInfos[dao].reputation;
    }

    /** Function to get the member's reputation
     * @param member The address of the member
     * @return The reputation of the member
     */
    function getMemberReputation(address member) external view returns (uint) {
        return memberInfos[member].memberReputation;
    }


    /* Setter Functions for basic info */


    /** Function to set the DAO's cap
     * @param dao The address of the DAO
     * @param cap The cap of the DAO
     */
    function setDaoCap(address dao, uint cap) external onlyOwnerOrGovernance {
        DaoInfo storage daoInfo = daoInfos[dao];
        daoInfo.daoCap = cap;
        daoInfos[dao] = daoInfo;
    }

    /** Function to set the DAO's tier threshold and number of tiers
     * @param dao The address of the DAO
     * @param threshold The tier threshold of the DAO
     * @param numberOfTier The number of tiers of the DAO
     */
    function setDaoTierNumberAndThreshold(address dao, uint threshold, uint numberOfTier) external onlyOwnerOrGovernance {
        DaoInfo storage daoInfo = daoInfos[dao];
        daoInfo.tierThreshold = threshold;
        daoInfo.numberOfTiers = numberOfTier;
        daoInfos[dao] = daoInfo;
    }

    /** Function to set the dao's data origin
     * @param dao The address of the DAO
     * @param weights The weights of the data origins
     * @param dataOrigins The addresses of the data origins
     */
    function setDaoDataOrigin(address dao, uint[] memory weights, address[] memory dataOrigins) external onlyOwnerOrGovernance {
        if (weights.length != dataOrigins.length) {
            revert InvalidLength();
        }

        uint totalWeight = 0;
        for (uint i = 0; i < weights.length; i++) {
            totalWeight += weights[i];
        }
        if (totalWeight != WEIGHT_DENOM) {
            revert InvalidWeights();
        }

        DaoInfo storage daoInfo = daoInfos[dao];
        daoInfo.weights = weights;
        daoInfo.dataOrigins = dataOrigins;

        daoInfos[dao] = daoInfo;
    }

    /** Function to set the protocol to DAO guarantee rate
     * @param dao The address of the DAO
     * @param rate The ratio of the protocol's guarantee to the DAO's guarantee in mantissa scale
     */
    function setProtocolGuaranteeRate(address dao, uint rate) external onlyOwnerOrGovernance {
        DaoInfo storage daoInfo = daoInfos[dao];
        daoInfo.protocolToDaoGuaranteeRate = rate;
        daoInfos[dao] = daoInfo;
    }


    /* Core Functions */


    /** Function to set calculate the member's cap
     * @param dao The address of the DAO
     * @param member The address of the member
     * @return The cap of the member excluding his collateral
     */
    function calculateMemberCap(address dao, address member) public returns (uint) {
        uint daoCap = this.getDaoCap(dao);
        uint daoReputationCap = _calculateDaoReputationCap(daoCap, daoInfos[dao].reputation);
        uint daoPointCap = daoCap - daoReputationCap;
        uint numberOfTiers = daoInfos[dao].numberOfTiers;
        uint tierThreshold = daoInfos[dao].tierThreshold;

        uint memberPoints = _getMemberPoints(dao, member);
        // 0 - 25 points = Tier D (1)
        // 26 - 50 points = Tier C (2) 
        // ...etc
        uint userPointTier = memberPoints.mulDiv(numberOfTiers, 100, Math.Rounding.Ceil);

        // If tierThreshold == 2, only Tier A and B can get the cap
        if (userPointTier > tierThreshold) {
            uint memberReputation = memberInfos[member].memberReputation;
            uint userReputationTier = memberReputation.mulDiv(numberOfTiers, 100, Math.Rounding.Ceil);
            uint memberCap =
                daoPointCap.mulDiv(userPointTier, numberOfTiers * 10) +
                daoReputationCap.mulDiv(userReputationTier, numberOfTiers * 10);
            // @TODO Consider collateral ratio of the member
            return memberCap.mulDiv(MANTISSA, calculateMemberCollateralRate(dao, member));
        } else {
            return 0;
        }  
    }

    /** Function to set the member's collateral ratio (100% - 500%) in mantissa scale
     * @dev If it is 1.8 * 1e18, the ratio he can get is 180%
     * @param dao The address of the DAO
     * @param member The address of the member
     */
    function calculateMemberCollateralRate(address dao, address member) public returns (uint) {
        uint memberDaoPoint = _getMemberPoints(dao, member);
        uint memberReputationPoint = memberInfos[member].memberReputation;
        
        uint daoCollateralRate = _calculateDaoMemberCollateralRate(memberDaoPoint);
        uint reputationCollateralRate = _calculateReputationCollateralRate(memberReputationPoint);

        return MANTISSA;
    }

    /** Function to change the member's cap
     * @param dao The address of the DAO
     * @param name The name of the DAO
     * @param daoCap The cap of the DAO
     * @param weights The weights of the data origins
     * @param dataOrigins The addresses of the data origins
     */
    function registerDao(
        address dao,
        string memory name,
        uint tierThreshold,
        uint numberOfTiers,
        uint daoCap,
        uint[] memory weights,
        address[] memory dataOrigins
    ) external onlyOwnerOrGovernance {
        if (weights.length != dataOrigins.length) {
            revert InvalidLength();
        }

        uint totalWeight = 0;
        for (uint i = 0; i < weights.length; i++) {
            totalWeight += weights[i];
        }
        if (totalWeight != WEIGHT_DENOM) {
            revert InvalidWeights();
        }

        uint initialReputation = 5000;

        DaoInfo storage daoInfo = daoInfos[dao];
        // e.g. Uniswap's name is "uniswapgovernance.eth"
        daoInfo.daoName = name;
        daoInfo.tierThreshold = tierThreshold;
        daoInfo.numberOfTiers = numberOfTiers;
        daoInfo.daoCap = daoCap;
        daoInfo.reputation = initialReputation;
        
        daoInfo.weights = weights;
        daoInfo.dataOrigins = dataOrigins;
        
        daoInfos[dao] = daoInfo;
    }

    /** Function to change the member's cap
     * @param quorum_ The quorum of the DAO
     */
    function setQuorum(uint quorum_) external onlyOwnerOrGovernance {
        _quorum = quorum_;
    }

    function modifyReputation(
        address dao,
        address member,
        uint amountEthValue,
        bool isUp
    ) external onlyComptroller {
        MemberInfo storage memberInfo = memberInfos[member];
        DaoInfo storage daoInfo = daoInfos[dao];

        uint memberReputation = memberInfo.memberReputation;
        uint daoReputation = daoInfo.reputation;
        // If member pays the loan back, he gets 1 points per 1 ETH
        // If member defaults, he loses 10 points per 1 ETH
        if (isUp) {
            memberReputation += amountEthValue.mulDiv(5, CHAINLINK_ORACLE_DENOM);
            daoReputation += amountEthValue.mulDiv(5, CHAINLINK_ORACLE_DENOM);
            if (memberReputation > 100) {
                memberReputation = 100;
            }
        } else {
            if (memberReputation < amountEthValue.mulDiv(25, CHAINLINK_ORACLE_DENOM)) {
                memberReputation = 0;
            } else {
                memberReputation -= amountEthValue.mulDiv(25, CHAINLINK_ORACLE_DENOM);
            }
            if (daoReputation < amountEthValue.mulDiv(25, CHAINLINK_ORACLE_DENOM)) {
                daoReputation = 0;
            } else {
                daoReputation -= amountEthValue.mulDiv(25, CHAINLINK_ORACLE_DENOM);
            }            
        }
    }


    /* Internal Functions */


    function _getMemberPoints(address dao, address user) internal returns (uint) {
        MemberInfo storage memberInfo = memberInfos[user];
        // This means that the user has not been used this protocol before
        if (!memberInfo.isEnrolled) {
            memberInfo.isEnrolled = true;
            // Initial member reputation score is 50
            memberInfo.memberReputation = 50;
        }
        memberInfos[user] = memberInfo;

        string memory daoName = daoInfos[dao].daoName;
        uint[] memory weights = daoInfos[dao].weights;
        address[] memory dataOrigins = daoInfos[dao].dataOrigins;
        uint points = 0;
        for (uint i = 0; i < weights.length; i++) {
            uint256 userScore = IFunctionsConsumer(dataOrigins[i]).userScore(daoName, user);
            points += userScore.mulDiv(weights[i], WEIGHT_DENOM);
        }
        return points;
    }

    function _calculateDaoMemberCollateralRate(uint memberDaoPoint) internal returns (uint) {
        // @TODO calculate the collateral rate based on dao point
        return MANTISSA;
    }

    function _calculateReputationCollateralRate(uint memberReputationPoint) internal returns (uint) {
        // @TODO calculate the collateral rate based on reputation point
        return MANTISSA;
    }

    function _calculateDaoReputationCap(uint daoCap, uint reputation) internal returns (uint) {
        // If the reputation is 5000, the reputation cap is 20% of the DAO cap
        return daoCap.mulDiv(4e13 * reputation, MANTISSA);
    }

    function _getComptrollerAddress() internal view returns (address) {
        return comptroller;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert InvalidAddress();
        }
        _;
    }

    modifier onlyOwnerOrGovernance() {
        if (msg.sender != owner) {
            _checkGovernance();
        }
        _;
    }

    modifier onlyDao(address dao) {
        if (msg.sender != dao) {
            revert InvalidAddress();
        }
        _;
    }

    modifier onlyComptroller() {
        if (msg.sender != _getComptrollerAddress()) {
            revert InvalidAddress();
        }
        _;
    }
}