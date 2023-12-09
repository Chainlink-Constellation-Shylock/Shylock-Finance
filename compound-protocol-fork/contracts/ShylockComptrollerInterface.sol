// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ComptrollerInterface.sol";

abstract contract ShylockComptrollerInterface is ComptrollerInterface{

    function addDaoReserveAllowed(address cToken, address dao, uint reserveAmount) virtual external returns (uint);
    function addMemberReserveAllowed(address cToken, address dao, address member, uint reserveAmount) virtual external returns (uint);
    function withdrawDaoReserveAllowed(address cToken, address dao, uint withdrawAmount) virtual external returns (uint);
    function withdrawMemberReserveAllowed(address cToken, address dao, address member, uint withdrawAmount) virtual external returns (uint);
    function borrowAllowed(address cToken, address dao, address borrower, uint borrowAmount) virtual external returns (uint);
    function getAccountReserve(address account) virtual external view returns (uint, uint);
    function getAccountBorrow(address account) virtual external view returns (uint, uint);
    function getAccountAllCtokenBalance(address account) virtual external view returns (uint, uint);

}