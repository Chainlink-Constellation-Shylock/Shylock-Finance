// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { ShylockGovernance } from "../../src/ShylockGovernance.sol";
import { MockConsumer } from "../mock/MockConsumer.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "../utils/fixtures/CompoundDeployment.sol";

contract ShylockGovernanceTest is Test, CompoundDeployment {
    using Math for uint;

    MockConsumer mockConsumer;
    ShylockComptroller mockComptroller;
    ShylockGovernance governance;

    // random address for dao
    address dao = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address member;
    string daoName = "MockDao";

    uint constant MANTISSA = 1e18;
    uint constant CHAINLINK_ORACLE_DENOM = 1e8;

    function setUp() virtual override public {
        super.setUp();
        member = borrower1;
        mockComptroller = ShylockComptroller(address(unitroller));
        (mockConsumer, governance) = initializeGovernanceContract(dao, daoName, address(mockComptroller), member);
    }

    function testGetDaoInfo() public {
        (
            string memory _daoName,
            uint _tierThreshold,
            uint _numberOfTiers,
            uint _daoCap,
            uint _protocolToDaoGuaranteeRate,
            uint _reputation
        ) = governance.daoInfos(dao);

        (uint[] memory _weights, address[] memory _dataOrigins) = governance.getDaoDataOrigin(dao);

        assertEq(_daoName, daoName);
        assertEq(_tierThreshold, 2);
        assertEq(_numberOfTiers, 4);
        assertEq(_daoCap, 100 * MANTISSA);
        assertEq(_protocolToDaoGuaranteeRate, 1 * MANTISSA);
        assertEq(_reputation, 5000);
        assertEq(_weights[0], 100);
        assertEq(_dataOrigins[0], address(mockConsumer));
    }

    function testGetMemberCollateralRate() public {
        uint memberCollateralRate = governance.calculateMemberCollateralRate(dao, member);
        (uint reputation,)= governance.memberInfos(member); 
        
        // expected collateral rate is 252.5%
        uint expectedCollateralRate = MANTISSA.mulDiv(505, 200);
        console.log("memberCollateralRate: ", memberCollateralRate);
        assertEq(reputation, 50);
        assertEq(memberCollateralRate, expectedCollateralRate);
    }

    function testGetMemberCap() public {
        uint memberCap = governance.getMemberCap(dao, member);
        
        // The member is on B Tier, whose tier = 3
        // The estimated member cap is 10.675 ETH
        uint expectedMemberCap = MANTISSA.mulDiv(10675, 1000);
        assertEq(memberCap, expectedMemberCap);
    }

    function testGetMemberReputationInterest() public {
        uint memberReputationInterest = governance.getReputationInterestRate(member);
        assertEq(memberReputationInterest, MANTISSA.mulDiv(10, 100));
    }

    function testSetDaoCap() public {
        governance.setDaoCap(dao, 200 * MANTISSA);
        uint daoCap = governance.getDaoCap(dao);
        assertEq(daoCap, 200 * MANTISSA);
    }

    function testSetProtocolToDaoGuaranteeRate() public {
        governance.setProtocolToDaoGuaranteeRate(dao, 2 * MANTISSA);
        uint protocolToDaoGuaranteeRate = governance.getProtocolToDaoGuaranteeRate(dao);
        assertEq(protocolToDaoGuaranteeRate, 2 * MANTISSA);
    }

    function testSetDaoTierNumberAndThreshold() public {
        governance.setDaoTierThresholdAndNumber(dao, 3, 5);
        (, uint _tierThreshold,uint _numberOfTiers,,,) = governance.daoInfos(dao);

        assertEq(_tierThreshold, 3);
        assertEq(_numberOfTiers, 5);
    }

    function testSetDaoDataOrigin() public {
        uint[] memory weights = new uint[](2);
        weights[0] = 50;
        weights[1] = 50;

        address[] memory dataOrigins = new address[](2);
        dataOrigins[0] = address(mockConsumer);
        // Just to test, the exact address does not matter
        dataOrigins[1] = address(mockConsumer);

        governance.setDaoDataOrigin(dao, weights, dataOrigins);
        (uint[] memory _weights, address[] memory _addresses) = governance.getDaoDataOrigin(dao);

        assertEq(_weights[0], 50);
        assertEq(_weights[1], 50);
        assertEq(_addresses[0], address(mockConsumer));
        assertEq(_addresses[1], address(mockConsumer));
    }

    function testSetQuorum() public {
        governance.setQuorum(200 * MANTISSA);
        uint quorum = governance.quorum(0);
        assertEq(quorum, 200 * MANTISSA);
    }

    function testModifyReputation() public {
        vm.startPrank(address(mockComptroller));
        governance.modifyReputation(dao, member, 50 * CHAINLINK_ORACLE_DENOM, true);
        uint reputation = governance.getMemberReputation(member);
        uint daoReputation = governance.getDaoReputation(dao);
        assertEq(reputation, 100);
        assertEq(daoReputation, 5050);

        governance.modifyReputation(dao, member, 10 * CHAINLINK_ORACLE_DENOM, false);
        reputation = governance.getMemberReputation(member);
        daoReputation = governance.getDaoReputation(dao);
        assertEq(reputation, 0);
        assertEq(daoReputation, 4950);
        vm.stopPrank();
    }


    /* Function to initialize governance contract */
    /* COPY this to use in other tests */

    function initializeGovernanceContract(
        address dao_,
        string memory daoName_,
        address comptroller,
        address member_
    ) public returns (MockConsumer, ShylockGovernance) {
        MockConsumer _mockConsumer = new MockConsumer();
        uint256[] memory weights = new uint256[](1); 
        weights[0] = 100;
        address[] memory dataOrigins = new address[](1);
        dataOrigins[0] = address(_mockConsumer);
        ShylockGovernance _governance = new ShylockGovernance(address(this), comptroller);

        _governance.registerDao(
            dao_,           // dao
            daoName_,       // daoName 
            2,              // tierThreshold
            4,              // numberOfTiers
            100 * 1e18,     // daoCap
            weights,        // weights
            dataOrigins     // dataOrigins
        );           

        // Just to initialize memberInfos
        _governance.getMemberCap(dao, member);

        return (_mockConsumer, _governance); 
    }
}
