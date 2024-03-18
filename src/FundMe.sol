// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address[] private s_funders;
    mapping(address => uint256) private s_addressAmountFunded;

    address private immutable i_owner;
    uint256 public constant minimumUsd = 5e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionPrice(s_priceFeed) >= minimumUsd,
            "didn't enough money"
        );
        s_funders.push(msg.sender);
        s_addressAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWhithdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function whithdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        //There are three methods to send ETH
        // //TRANSFER
        //payable(msg.sender).transfer(address(this).balance);

        // //SEND
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, 'Send failed');

        // //CALL
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    //make sure the owner is the one who can withdraw
    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not the owner");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAdressAmountFunded(
        address fundingAdress
    ) external view returns (uint256) {
        return s_addressAmountFunded[fundingAdress];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
