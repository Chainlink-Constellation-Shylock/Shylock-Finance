// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { ShylockGovernance } from "../src/ShylockGovernance.sol";
import { MockConsumer } from "./mock/MockConsumer.sol";
import { MockComptroller } from "./mock/MockComptroller.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IGovernor } from "@openzeppelin/contracts/governance/IGovernor.sol";

contract ShylockGovernanceVoteTest is Test {
    using Math for uint;

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    MockConsumer mockConsumer;
    MockComptroller mockComptroller;
    ShylockGovernance governance;

    // random address for dao
    address dao = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address member = address(0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD);
    string daoName = "MockDao";

    uint constant MANTISSA = 1e18;
    uint constant CHAINLINK_ORACLE_DENOM = 1e8;
    uint proposalId;

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 voteStart,
        uint256 voteEnd,
        string description
    );
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);


    function setUp() public {
        mockComptroller = new MockComptroller();
        (mockConsumer, governance) = initializeGovernanceContract(dao, daoName, address(mockComptroller), member);
        proposalId = proposeOne();
    }

    function testVote() public {
        // Move to the next block
        vm.warp(2);
        IGovernor.ProposalState state = governance.state(proposalId);
        console.log(uint(state));
        // Start the vote
        vm.startPrank(member);

        vm.expectEmit(true, true, true, true);
        // CToken balance is hardcoded to 100 in test cases
        emit VoteCast(member, proposalId, 1, 100, "");
        governance.castVoteWithReason(proposalId, 1, "");
        vm.stopPrank();
    }

    function proposeOne() public returns(uint256 _proposalId) {
        address[] memory targets = new address[](1);
        targets[0] = address(governance);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature(
            "setDaoCap(address,uint)",
            dao,
            200 * 1e18
        );
        string memory description = "";

        uint256 expectedProposalId = governance.hashProposal(
            targets,
            values,
            calldatas,
            keccak256(bytes(description))
        );
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(
            expectedProposalId,
            address(this),
            targets,
            values,
            new string[](1),
            calldatas,
            block.number,
            block.number + 21 days,
            description
        );
        _proposalId = governance.propose(
            targets,
            values,
            calldatas,
            description
        );
    }

    function initializeGovernanceContract(
        address dao_,
        string memory daoName_,
        address comptroller,
        address member_
    ) public returns (MockConsumer, ShylockGovernance) {
        MockConsumer _mockConsumer = new MockConsumer();
        _mockConsumer.setScore(daoName_, member_, 60);
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
