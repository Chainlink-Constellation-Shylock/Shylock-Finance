// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import { ShylockGovernanceInterface } from "./interfaces/ShylockGovernanceInterface.sol";
import { ShylockGovernanceVote } from "./ShylockGovernanceVote.sol";
import { IFunctionsConsumer } from "./interfaces/IFunctionsConsumer.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract ShylockGovernance is ShylockGovernanceInterface, ShylockGovernanceVote {
    using Math for uint256;

    address public owner;
    address public comptroller;

    constructor(address _owner, address _comptroller) ShylockGovernanceVote("Shylock") {
        owner = _owner;
        comptroller = _comptroller;
    }

    /* Getter Functions for basic info */

    function getDaoDataInfo(address dao) external view returns (uint[] memory, address[] memory) {
        return (DaoDataInfos[dao].weights, DaoDataInfos[dao].dataOrigins);
    }

    function getDaoCap(address dao) override external view returns (uint) {
        return daoCap[dao];
    }

    /** Protocol / DAO -> 1e18 scale
     * @dev 
     */
    function getProtocolToDaoGuaranteeRate(address dao) override external view returns (uint) {
        return protocolToDaoGuaranteeRate[dao];
    }

    function getMemberCap(address dao, address member) override external returns (uint) {
        return calculateMemberCap(dao, member);
    }

    function getMemberCollateralRate(address member) override view external returns (uint) {
        return memberGuaranteeRate[member];
    }

    /* Setter Functions for basic info */

    function setDaoCap(address dao, uint cap) external onlyOwnerOrGovernance {
        daoCap[dao] = cap;
    }

    function setProtocolGuaranteeRate(address dao, uint rate) external onlyOwnerOrGovernance {
        protocolToDaoGuaranteeRate[dao] = rate;
    }

    // @TODO Add logic to calculate member cap based on member's points
    function calculateMemberCap(address dao, address member) public returns (uint) {
        uint daoCap = this.getDaoCap(dao);
        uint memberPoints = _getMemberPoints(dao, member);
        memberGuaranteeRate[member] = memberGuaranteeRate[member] == 0 ? 100 : memberGuaranteeRate[member];
        return 10;
    }

    function setDaoDataOrigin(uint[] memory weights, address[] memory dataOrigins) external onlyOwnerOrGovernance {
        if (weights.length != dataOrigins.length) {
            revert InvalidLength();
        }
        DaoDataInfos[msg.sender] = DaoDataInfo(weights, dataOrigins);
    }

    function registerDaoName(address dao, string memory name) external onlyOwnerOrGovernance {
        daoNames[dao] = name;
    }

    /* Internal Functions */

    function _getMemberPoints(address dao, address user) internal view returns (uint) {
        string memory daoName = daoNames[dao];
        uint[] memory weights = DaoDataInfos[dao].weights;
        address[] memory dataOrigins = DaoDataInfos[dao].dataOrigins;
        uint points = 0;
        for (uint i = 0; i < weights.length; i++) {
            uint256 userScore = IFunctionsConsumer(dataOrigins[i]).userScore(daoName, user);
            points += userScore.mulDiv(weights[i], WEIGHT_DENOM);
        }
        return points;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert InvalidOwner();
        }
        _;
    }

    modifier onlyOwnerOrGovernance() {
        if (msg.sender != owner) {
            _checkGovernance();
        }
        _;
    }
}