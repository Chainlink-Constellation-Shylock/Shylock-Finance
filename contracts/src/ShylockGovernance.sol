// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import { ShylockGovernanceInterface } from "./interfaces/ShylockGovernanceInterface.sol";

contract ShylockGovernance is ShylockGovernanceInterface {
    mapping (address => string) public daoNames;
    mapping(address => uint) public daoCap;
    mapping(address => uint) public protocolGuaranteeRate;
    mapping(address => uint) public memberCap;
    mapping(address => uint) public memberGuaranteeRate;

    function getDaoCap(address dao) override external view returns (uint) {
        return daoCap[dao];
    }

    function getProtoclGuaranteeRate(address dao) override external view returns (uint) {
        return protocolGuaranteeRate[dao];
    }

    function getMemberCap(address member) override external view returns (uint) {
        return memberCap[member];
    }

    function getMemberGuaranteeRate(address member) override view external returns (uint) {
        return memberGuaranteeRate[member];
    }

    function setDaoCap(address dao, uint cap) external {
        daoCap[dao] = cap;
    }

    function setProtocolGuaranteeRate(address dao, uint rate) external {
        protocolGuaranteeRate[dao] = rate;
    }

    function setMemberCap(address member, uint cap) external {
        memberCap[member] = cap;
    }

    function setDaoName(address dao, string memory name) external {
        daoNames[dao] = name;
    }

    function setMemberGuaranteeRate(address member, uint rate) external {
        memberGuaranteeRate[member] = rate;
    }
}