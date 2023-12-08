// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

contract ShylockCTokenStorage {
    mapping (address => uint) public underlyingReserves;
    mapping (address => uint) public underlyingGuarantee;    
}

abstract contract ShylockCTokenInterface is ShylockCTokenStorage {
    event AddDaoReserve(address indexed dao, uint actualReserveAmount, uint newTotalReserveAmount);
    event AddMemberReserve(address indexed member, uint actualReserveAmount, uint newTotalReserveAmount);
}

