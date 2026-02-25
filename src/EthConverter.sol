// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library EthConverter {
    // returning price of 1 eth in usd from chainlink
    // FIXED CODE
    function getPrice(AggregatorV3Interface ethPriceInUSD) internal view returns (uint256) {
        (, int256 answer,,,) = ethPriceInUSD.latestRoundData();
        return uint256(answer * 1e10);
    }

    // getting total amout of eth in dollars

    function convertingDepositedEthToUSD(uint256 depositedEth, AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 priceOfEth = getPrice(priceFeed);

        uint256 ethCoversion = (depositedEth * priceOfEth) / 1e18;
        return ethCoversion;
    }
}
