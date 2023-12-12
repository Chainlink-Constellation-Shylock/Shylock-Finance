// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;

import { GovernorCountingSimple } from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import { Governor } from "@openzeppelin/contracts/governance/Governor.sol";
import { ShylockComptrollerInterface } from "./interfaces/ShylockComptrollerInterface.sol";

/* This contract is based on Openzeppelin Governor contract */
/* It reflects exact vote rights based on the USD value of CTokens */
/* The execution part will be at ShylockGovernance.sol, which inherits this contract */

abstract contract ShylockGovernanceVote is GovernorCountingSimple {
    error NotImplemented();

    address public comptroller;
    // 100 ETH initially, but can be changed by DAO
    uint256 _quorum = 100 * 1e8;

    constructor (string memory name, address _comptroller) Governor(name) {
        comptroller = _comptroller;
    }

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
        return uint48(block.timestamp);
    }

    function quorum(uint256 /* timepoint */) public view override returns (uint256) {
        return _quorum;
    }

    function votingDelay() public view override returns (uint256) {
        return 0;
    }

    function votingPeriod() public view override returns (uint256) {
        return 21 days;  // 14 days in production
    }

    /** Function to get the votes of an account at a certain timepoint
     * @param account The address of the account
     * @return The votes of the account in the form of oracle price (CToken/ETH)
     */ 
    function _getVotes(
        address account,
        uint256 /* timepoint */,
        bytes memory /* params */
    ) internal view override returns (uint256) {
        (uint whatError, uint cTokenBalance) = ShylockComptrollerInterface(comptroller).getAllAccountCtokenBalance(account);
        if (whatError != 0) {
            return 0;
        }
        return cTokenBalance;
    }
}