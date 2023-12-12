// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/interfaces/AggregatorV3Interface.sol";
import { PriceOracle } from "./compound/PriceOracle.sol";
import { CToken } from "./compound/CToken.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED
 * VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract ShylockOracle is PriceOracle {
    AggregatorV3Interface internal avaxUsdDataFeed;
    AggregatorV3Interface internal ethUsdDataFeed;
    address cTokenAddr;
    mapping(address => uint256) tokenPrice;

    constructor(address cToken) {
        cTokenAddr = cToken;
        tokenPrice[cTokenAddr] = 1000000000000000; // 0.001 * 10**18
        avaxUsdDataFeed = AggregatorV3Interface(
            0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
        );
        ethUsdDataFeed = AggregatorV3Interface(
            0x86d67c3D38D2bCeE722E601025C25a575021c6EA
        );
    }

    function setDirectPrice(address asset, uint256 _price) public {
        tokenPrice[asset] = _price;
    }

    function getUnderlyingPrice(CToken cToken) override external view returns (uint) {
        address tokenAddr = address(cToken);
        if (tokenAddr == 0xA0A92Fc977b988955d82cd53380c9ba762AA1046) {
            return tokenPrice[tokenAddr];
        } else if (tokenAddr == address(0)) {
            return uint(getAvaxEthChainlinkDataFeedLatestAnswer());
        } else {
            return tokenPrice[tokenAddr];
        }
    }
    /**
     * Returns the latest answer.
     */
    function getAvaxEthChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int avaxUsd,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = avaxUsdDataFeed.latestRoundData();
        // prettier-ignore
        (
            /* uint80 roundID */,
            int ethUsd,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = ethUsdDataFeed.latestRoundData();

        // @dev returns data in 8 decimals
        return avaxUsd * 10**8 / ethUsd;
    }
}
