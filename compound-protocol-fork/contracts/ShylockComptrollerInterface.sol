// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ComptrollerInterface.sol";

abstract contract ShylockComptrollerInterface is ComptrollerInterface{

    function addDaoReserveAllowed(address cToken, address dao, uint reserveAmount) virtual external returns (uint);
    function addMemberReserveAllowed(address cToken, address member, uint reserveAmount) virtual external returns (uint);
    function borrowAllowed(address cToken, address dao, address borrower, uint borrowAmount) virtual external returns (uint);
    function getAccountAllCtokenBalance(address account) virtual external view returns (uint, uint);

}