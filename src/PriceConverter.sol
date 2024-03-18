// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

//compiling an interface help us to get the ABI

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //whenever we interact with another contract
        //we need the address and the ABI of the contract
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // 200.0000000
        return uint256(price * 1e10);
    }

    function getConversionPrice(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}
