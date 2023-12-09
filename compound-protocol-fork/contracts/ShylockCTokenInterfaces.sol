// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

contract ShylockCTokenStorage {
    struct borrowContract {
        uint principal;
        uint memberCollateral;
        uint daoCollateral;
        uint protocolCollateral;
        uint interestIndex;
        uint openTimestamp;
        uint dueTimestamp;
    }
    mapping (address => borrowContract[]) public borrowContracts;

    mapping (address => uint) public underlyingReserve;
    mapping (address => uint) public underlyingGuarantee;    

}

abstract contract ShylockCTokenInterface is ShylockCTokenStorage {
    event AddDaoReserve(address indexed dao, uint actualReserveAmount, uint newTotalReserveAmount);
    event AddMemberReserve(address indexed member, uint actualReserveAmount, uint newTotalReserveAmount);
}

