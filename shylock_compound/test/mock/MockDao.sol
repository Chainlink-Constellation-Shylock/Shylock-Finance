// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ShylockCErc20} from "../../src/ShylockCErc20.sol";

contract MockDao {
  function execute(address target, bytes memory data) external {
    (bool success, bytes memory result) = target.call(data);
    require(success, string(result));
  }
  function addDaoReserve(address shErc20, uint amount) external {
    uint res = ShylockCErc20(shErc20).addDaoReserve(amount);
    require(res == 0, "addDaoReserve failed");
  }
}