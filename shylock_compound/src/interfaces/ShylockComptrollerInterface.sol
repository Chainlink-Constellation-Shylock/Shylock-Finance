// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;

import "../compound/ComptrollerInterface.sol";
import "./ShylockGovernanceInterface.sol";

abstract contract ShylockComptrollerInterface is ComptrollerInterface{
    function getAllAccountCtokenBalance(address account) virtual external view returns (uint, uint);
    function getAllAccountReserve(address account) virtual external view returns (uint, uint);
    function getAllAccountBorrow(address account) virtual external view returns (uint, uint);
    function addDaoReserveAllowed(address cToken, address dao, uint reserveAmount) virtual external returns (uint);
    function addMemberReserveAllowed(address cToken, address dao, address member, uint reserveAmount) virtual external returns (uint);
    function withdrawDaoReserveAllowed(address cToken, address dao, uint withdrawAmount) virtual external returns (uint);
    function withdrawMemberReserveAllowed(address cToken, address dao, address member, uint withdrawAmount) virtual external returns (uint);
    function borrowAllowed(address cToken, address dao, address borrower, uint borrowAmount) virtual external returns (uint);
    function setGovernanceContract(ShylockGovernanceInterface _governanceContract) virtual external;
}