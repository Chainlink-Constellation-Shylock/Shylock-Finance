// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

abstract contract ShylockComptrollerInterface {

    function addDaoReserveAllowed(address cToken, address dao, uint reserveAmount) virtual external returns (uint);

}