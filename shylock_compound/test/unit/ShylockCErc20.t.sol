// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./ShylockGovernance.t.sol";
import { ShylockCTokenStorage } from "../../src/interfaces/ShylockCTokenInterfaces.sol";

contract ShylockCErc20Test is ShylockGovernanceTest, ShylockCTokenStorage {

    function setUp() override public {
        super.setUp();
        vm.deal(dao, 100000000000 ether);
        mintDai(dao, 100000000000 ether);
        mintDai(borrower1, 100000000000 ether);
        vm.startPrank(owner);
        mockComptroller.setGovernanceContract(governance);
        vm.stopPrank();
    }

    function _testMint(address acount, uint mintAmount) internal returns (uint) {
        vm.startPrank(acount);
        uint beforeLenderUnderlyingBalance = daiToken.balanceOf(acount);
        uint beforeLenderCTokenBalance = bDAI.balanceOf(acount);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("before lender's daibalance", beforeLenderCTokenBalance);
        console.log("before lender's cTokenbalance", beforeLenderUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);

        daiToken.approve(address(bDAI), mintAmount);
        bDAI.mint(mintAmount);

        uint afterLenderCTokenbalance = bDAI.balanceOf(acount);
        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        uint afterLenderUnderlyingBalance = daiToken.balanceOf(acount);
        console.log("after lender's cTokenbalance", afterLenderCTokenbalance);
        console.log("after lender's underlyingBalance", afterLenderUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        assertEq(afterLenderUnderlyingBalance, beforeLenderUnderlyingBalance-mintAmount);
        assertEq(afterContractUnderlyingBalance, beforeContractUnderlyingBalance+mintAmount);
        vm.stopPrank();
        return afterLenderCTokenbalance;
    }

    function testMint() public {
        _testMint(lender1, 1000 ether);
    }

    function _testRedeem(address acount, uint redeemTokens) internal returns (uint) {
        vm.startPrank(acount);
        uint beforeLenderUnderlyingBalance = daiToken.balanceOf(acount);
        uint beforeLenderCTokenBalance = bDAI.balanceOf(acount);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("before lender's daibalance", beforeLenderCTokenBalance);
        console.log("before lender's cTokenbalance", beforeLenderUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);

        bDAI.redeem(redeemTokens);

        uint afterLenderCTokenbalance = bDAI.balanceOf(acount);
        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        uint afterLenderUnderlyingBalance = daiToken.balanceOf(acount);
        console.log("after lender's cTokenbalance", afterLenderCTokenbalance);
        console.log("after lender's underlyingBalance", afterLenderUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        assertEq(afterLenderCTokenbalance, beforeLenderCTokenBalance-redeemTokens);
        vm.stopPrank();
        return afterLenderUnderlyingBalance-beforeLenderUnderlyingBalance;
    }

    function testRedeem() public {
        uint deltaCTokenBalance= _testMint(lender1, 1000 ether);
        uint deltaUnderlyingBalance = _testRedeem(lender1, deltaCTokenBalance);
        assertEq(deltaUnderlyingBalance, 1000 ether);
    }

    function _testAddDaoRserve(uint reserveAmount) internal returns (uint) {
        vm.startPrank(dao);
        console.log("dao cap", governance.getDaoCap(dao));
        console.log("governane address", address(governance));
        console.log("governance address", address(mockComptroller.governanceContract()));
        uint beforeDaoReserve = bDAI.shylockReserve(dao);
        uint beforeDaoUnderlyingBalance = daiToken.balanceOf(dao);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("before daoReserve", beforeDaoReserve);
        console.log("before dao's underlyingBalance", beforeDaoUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);

        daiToken.approve(address(bDAI), reserveAmount);
        bDAI.addDaoReserve(reserveAmount);
        // uint result = mockComptroller.addDaoReserveAllowed(address(bDAI), dao, reserveAmount);
        // console.log("result", result);

        uint afterDaoReserve = bDAI.shylockReserve(dao);
        uint afterDaoUnderlyingBalance = daiToken.balanceOf(dao);
        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("after daoReserve", afterDaoReserve);
        console.log("after dao's underlyingBalance", afterDaoUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        assertEq(afterDaoReserve, beforeDaoReserve+reserveAmount);
        vm.stopPrank();
        return afterDaoReserve-beforeDaoReserve;
    }

    function testAddDaoReserve() public {
        _testAddDaoRserve(50 ether);
    }

    function _testWithdrawDaoReserve(uint withdrawAmount) internal returns (uint) {
        vm.startPrank(dao);
        uint beforeDaoReserve = bDAI.shylockReserve(dao);
        uint beforeDaoUnderlyingBalance = daiToken.balanceOf(dao);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("before daoReserve", beforeDaoReserve);
        console.log("before dao's underlyingBalance", beforeDaoUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);

        bDAI.withdrawDaoReserve(withdrawAmount);

        uint afterDaoReserve = bDAI.shylockReserve(dao);
        uint afterDaoUnderlyingBalance = daiToken.balanceOf(dao);
        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("after daoReserve", afterDaoReserve);
        console.log("after dao's underlyingBalance", afterDaoUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        assertEq(afterDaoReserve, beforeDaoReserve-withdrawAmount);
        assertEq(afterDaoUnderlyingBalance, beforeDaoUnderlyingBalance+withdrawAmount);
        vm.stopPrank();
        return afterDaoUnderlyingBalance-beforeDaoUnderlyingBalance;
    }

    function testWithdrawDaoReserve() public {
        uint deltaUnderlyingBalance = _testAddDaoRserve(50 ether);
        _testWithdrawDaoReserve(deltaUnderlyingBalance);
    }

    function _addMemberReserve(address dao, address member, uint reserveAmount) internal returns (uint) {
        vm.startPrank(member);
        uint beforeMemberReserve = bDAI.shylockReserve(member);
        uint beforeMemberUnderlyingBalance = daiToken.balanceOf(member);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("before memberReserve", beforeMemberReserve);
        console.log("before member's underlyingBalance", beforeMemberUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);

        daiToken.approve(address(bDAI), reserveAmount);
        bDAI.addMemberReserve(dao, reserveAmount);

        uint afterMemberReserve = bDAI.shylockReserve(member);
        uint afterMemberUnderlyingBalance = daiToken.balanceOf(member);
        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("after memberReserve", afterMemberReserve);
        console.log("after member's underlyingBalance", afterMemberUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        assertEq(afterMemberReserve, beforeMemberReserve+reserveAmount);
        vm.stopPrank();
        return afterMemberReserve-beforeMemberReserve;
    }

    function testAddMemberReserve() public {
        _addMemberReserve(dao, borrower1, 50 ether);
    }

    function _testWithdrawMemberReserve(address dao, address member, uint withdrawAmount) internal returns (uint) {
        vm.startPrank(member);
        uint beforeMemberReserve = bDAI.shylockReserve(member);
        uint beforeMemberUnderlyingBalance = daiToken.balanceOf(member);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("before memberReserve", beforeMemberReserve);
        console.log("before member's underlyingBalance", beforeMemberUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);

        bDAI.withdrawMemberReserve(dao, withdrawAmount);

        uint afterMemberReserve = bDAI.shylockReserve(member);
        uint afterMemberUnderlyingBalance = daiToken.balanceOf(member);
        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        console.log("after memberReserve", afterMemberReserve);
        console.log("after member's underlyingBalance", afterMemberUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        assertEq(afterMemberReserve, beforeMemberReserve-withdrawAmount);
        assertEq(afterMemberUnderlyingBalance, beforeMemberUnderlyingBalance+withdrawAmount);
        vm.stopPrank();
        return afterMemberUnderlyingBalance-beforeMemberUnderlyingBalance;
    }

    function testWithdrawMemberReserve() public {
        uint deltaUnderlyingBalance = _addMemberReserve(dao, borrower1, 50 ether);
        _testWithdrawMemberReserve(dao, borrower1, deltaUnderlyingBalance);
    }

    function _testBorrow(address borrower, uint borrowAmount) internal returns (uint) {
        vm.startPrank(borrower);
        uint beforeBorrowerUnderlyingBalance = daiToken.balanceOf(borrower);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        uint beforeBorrowerReserve = bDAI.shylockReserve(borrower);
        uint beforeDaoReserve = bDAI.shylockReserve(dao);
        uint beforeBorrowerGuarantee = bDAI.getAccountGuarantee(borrower);
        uint beforeDaoGuarantee = bDAI.getAccountGuarantee(dao);
        console.log("before borrower's underlyingBalance", beforeBorrowerUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);
        console.log("before borrower's reserve", beforeBorrowerReserve);
        console.log("before dao's reserve", beforeDaoReserve);
        console.log("before borrower's guarantee", beforeBorrowerGuarantee);
        console.log("before dao's guarantee", beforeDaoGuarantee);

        bDAI.borrow(dao,block.timestamp+1000,borrowAmount);

        uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        uint afterBorrowerUnderlyingBalance = daiToken.balanceOf(borrower);
        uint afterBorrowerReserve = bDAI.shylockReserve(borrower);
        uint afterDaoReserve = bDAI.shylockReserve(dao);
        uint afterBorrowerGuarantee = bDAI.getAccountGuarantee(borrower);
        uint afterDaoGuarantee = bDAI.getAccountGuarantee(dao);
        console.log("after borrower's underlyingBalance", afterBorrowerUnderlyingBalance);
        console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        console.log("after borrower's reserve", afterBorrowerReserve);
        console.log("after dao's reserve", afterDaoReserve);
        console.log("after borrower's guarantee", afterBorrowerGuarantee);
        console.log("after dao's guarantee", afterDaoGuarantee);

        {
            borrowContract memory borrowContract_ = bDAI.getBorrowContractdByIndex(borrower1, 0);
            // struct borrowContract {
            //     address dao;
            //     uint principal;
            //     uint memberCollateral;
            //     uint daoCollateral;
            //     uint protocolCollateral;
            //     uint interestIndex;
            //     uint openTimestamp;
            //     uint dueTimestamp;
            // }
            console.log("borrowContract principal", borrowContract_.principal);
            console.log("borrowContract memberCollateral", borrowContract_.memberCollateral);
            console.log("borrowContract daoCollateral", borrowContract_.daoCollateral);
            console.log("borrowContract protocolCollateral", borrowContract_.protocolCollateral);
            console.log("borrowContract interestIndex", borrowContract_.interestIndex);
            console.log("borrowContract openTimestamp", borrowContract_.openTimestamp);
            console.log("borrowContract dueTimestamp", borrowContract_.dueTimestamp);
        }
        

        assertEq(afterBorrowerUnderlyingBalance, beforeBorrowerUnderlyingBalance+borrowAmount);
        vm.stopPrank();
        return afterBorrowerUnderlyingBalance-beforeBorrowerUnderlyingBalance;
    }

    function testBorrow() public {
        _testMint(lender1, 1000 ether);
        _testAddDaoRserve(50 ether);
        _addMemberReserve(dao, borrower1, 10 ether);
        _testBorrow(borrower1, 5 ether);
    }

    function _repayBorrow(address borrower, uint repayAmount, uint index) internal returns (uint) {
        vm.startPrank(borrower);
        uint beforeBorrowerUnderlyingBalance = daiToken.balanceOf(borrower);
        uint beforeContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        uint beforeBorrowerReserve = bDAI.shylockReserve(borrower);
        uint beforeDaoReserve = bDAI.shylockReserve(dao);
        uint beforeBorrowerGuarantee = bDAI.getAccountGuarantee(borrower);
        uint beforeDaoGuarantee = bDAI.getAccountGuarantee(dao);
        console.log("before borrower's underlyingBalance", beforeBorrowerUnderlyingBalance);
        console.log("before cToken's underlyingBalance", beforeContractUnderlyingBalance);
        console.log("before borrower's reserve", beforeBorrowerReserve);
        console.log("before dao's reserve", beforeDaoReserve);
        console.log("before borrower's guarantee", beforeBorrowerGuarantee);
        console.log("before dao's guarantee", beforeDaoGuarantee);

        daiToken.approve(address(bDAI), repayAmount);
        bDAI.repayBorrow(dao, repayAmount, index);

        // uint afterContractUnderlyingBalance = daiToken.balanceOf(address(bDAI));
        uint afterBorrowerUnderlyingBalance = daiToken.balanceOf(borrower);
        // uint afterBorrowerReserve = bDAI.shylockReserve(borrower);
        // uint afterDaoReserve = bDAI.shylockReserve(dao);
        // uint afterBorrowerGuarantee = bDAI.getAccountGuarantee(borrower);
        // uint afterDaoGuarantee = bDAI.getAccountGuarantee(dao);
        // console.log("after borrower's underlyingBalance", afterBorrowerUnderlyingBalance);
        // console.log("after cToken's underlyingBalance", afterContractUnderlyingBalance);
        // console.log("after borrower's reserve", afterBorrowerReserve);
        // console.log("after dao's reserve", afterDaoReserve);
        // console.log("after borrower's guarantee", afterBorrowerGuarantee);
        // console.log("after dao's guarantee", afterDaoGuarantee);

        {
            borrowContract memory borrowContract_ = bDAI.getBorrowContractdByIndex(borrower1, 0);
            // struct borrowContract {
            //     address dao;
            //     uint principal;
            //     uint memberCollateral;
            //     uint daoCollateral;
            //     uint protocolCollateral;
            //     uint interestIndex;
            //     uint openTimestamp;
            //     uint dueTimestamp;
            // }
            console.log("borrowContract principal", borrowContract_.principal);
            console.log("borrowContract memberCollateral", borrowContract_.memberCollateral);
            console.log("borrowContract daoCollateral", borrowContract_.daoCollateral);
            console.log("borrowContract protocolCollateral", borrowContract_.protocolCollateral);
            console.log("borrowContract interestIndex", borrowContract_.interestIndex);
            console.log("borrowContract openTimestamp", borrowContract_.openTimestamp);
            console.log("borrowContract dueTimestamp", borrowContract_.dueTimestamp);
        }

        assertEq(afterBorrowerUnderlyingBalance, beforeBorrowerUnderlyingBalance-repayAmount);
        vm.stopPrank();
        return beforeBorrowerUnderlyingBalance-afterBorrowerUnderlyingBalance;
    }

    function testRepayBorrow() public {
        console.log("Current block number", block.number);
        testBorrow();
        uint256 blocksToSkip = 20;
        for (uint256 i = 0; i < blocksToSkip; ++i) {
            vm.roll(block.number + 1);
        }
        console.log("Current block number", block.number);

        borrowContract memory borrowContract_ = bDAI.getBorrowContractdByIndex(borrower1, 0);
        console.log("borrowContract principal", borrowContract_.principal);
        console.log("borrowContract memberCollateral", borrowContract_.memberCollateral);
        console.log("borrowContract daoCollateral", borrowContract_.daoCollateral);
        console.log("borrowContract protocolCollateral", borrowContract_.protocolCollateral);
        console.log("borrowContract interestIndex", borrowContract_.interestIndex);
        console.log("borrowContract openTimestamp", borrowContract_.openTimestamp);
        console.log("borrowContract dueTimestamp", borrowContract_.dueTimestamp);

        _repayBorrow(borrower1, borrowContract_.principal, 0);
    }

}