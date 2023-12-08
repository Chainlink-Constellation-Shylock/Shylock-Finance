// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import { GovernorCountingSimple } from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import { Governor } from "@openzeppelin/contracts/governance/Governor.sol";

/* This contract is a variation of Openzeppelin Governor contract */
/* It reflects exact vote rights based on the USD value of CTokens */
/* The execution part will be at ShylockGovernance.sol, which inherits this contract */

abstract contract ShylockGovernanceVote is GovernorCountingSimple {
    error NotImplemented();

    constructor (string memory name) Governor(name) {}
    
    function castVoteBySig(
        uint256 /* proposalId */,
        uint8 /* support */,
        address /* voter */,
        bytes memory /* signature */
    ) public virtual override returns (uint256) {
        revert NotImplemented();
    }

    /**
     * @dev See {IGovernor-castVoteWithReasonAndParamsBySig}.
     */
    function castVoteWithReasonAndParamsBySig(
        uint256 /* proposalId */,
        uint8 /* support */,
        address /* voter */,
        string calldata /* reason */,
        bytes memory /* params */,
        bytes memory /* signature */
    ) public virtual override returns (uint256) {
        revert NotImplemented();
    }

    function CLOCK_MODE() public view override returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    function clock() public view override returns (uint48) {
        return uint48(block.number);
    }

    function quorum(uint256 timepoint) public view override returns (uint256) {
        return 0;
    }

    function votingDelay() public view override returns (uint256) {
        return 0;
    }

    function votingPeriod() public view override returns (uint256) {
        return 1 days;  // 14 days in production
    }

    // @TODO implement this function
    function _getVotes(
        address account,
        uint256 timepoint,
        bytes memory params
    ) internal view override returns (uint256) {
        return 0;
    }
}