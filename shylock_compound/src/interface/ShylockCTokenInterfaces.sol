// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

contract ShylockCTokenStorage {
    struct borrowContract {
        address dao;
        uint principal;
        uint memberCollateral;
        uint daoCollateral;
        uint protocolCollateral;
        uint interestIndex;
        uint openTimestamp;
        uint dueTimestamp;
    }
    mapping (address => borrowContract[]) public borrowContracts;

    struct guaranteeSnapshot {
        uint principal;
        uint interestIndex;
    }

    mapping (address => uint) public shylockReserve;
    // mapping (address => uint) public shylockGuarantee;
    mapping (address => guaranteeSnapshot) public shylockGuarantee;

    uint public totalShylockReserve;

    address public ccipGateWay;

}

abstract contract ShylockCTokenInterface is ShylockCTokenStorage {
    event AddDaoReserve(address indexed dao, uint actualReserveAmount, uint newTotalReserveAmount);
    event AddMemberReserve(address indexed member, uint actualReserveAmount, uint newTotalReserveAmount);
    event WithdrawDaoReserve(address indexed dao, uint actualWithdrawAmount, uint newTotalReserveAmount);
    event WithdrawMemberReserve(address indexed member, uint actualWithdrawAmount, uint newTotalReserveAmount);
}

