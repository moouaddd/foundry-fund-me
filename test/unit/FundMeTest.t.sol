// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsd() public {
        assertEq(fundMe.minimumUsd(), 5e18);
    }

    function testIsOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionPrice() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFail() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundSuccess() public User {
        uint256 amountFunded = fundMe.getAdressAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToAnArray() public User {
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerWithdraw() public User {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.whithdraw();
    }

    function testWithdrawSingleFunder() public User {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startinFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.whithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundeMeBalance = address(fundMe).balance;

        assertEq(endingFundeMeBalance, 0);
        assertEq(
            startinFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testMultipleFunders() public User {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = numberOfFunders; i > numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE};
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startinFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.whithdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(
            startinFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }

    function testCheaperMultipleFunders() public User {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = numberOfFunders; i > numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE};
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startinFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWhithdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(
            startinFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }

    modifier User() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
