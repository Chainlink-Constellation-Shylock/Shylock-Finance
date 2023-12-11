// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/interfaces/AggregatorV3Interface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED
 * VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract DataConsumerV3 {
    AggregatorV3Interface internal avaxUsdDataFeed;
    AggregatorV3Interface internal ethUsdDataFeed;
    address mockTokenAddr = 0xA0A92Fc977b988955d82cd53380c9ba762AA1046;
    mapping(address => int256) tokenPrice;

    constructor() {
        avaxUsdDataFeed = AggregatorV3Interface(
            0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
        );
        ethUsdDataFeed = AggregatorV3Interface(
            0x86d67c3D38D2bCeE722E601025C25a575021c6EA
        );
    }

    function setDirectPrice(address asset, int256 _price) public {
        tokenPrice[asset] = _price;
    }

    function getUnderlyingPrice(address token) public view returns (int) {
        if (token == 0xA0A92Fc977b988955d82cd53380c9ba762AA1046) {
            return tokenPrice[token];
        } else if (token == address(0)) {
            return getAvaxEthChainlinkDataFeedLatestAnswer();
        } else {
            return tokenPrice[token];
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
