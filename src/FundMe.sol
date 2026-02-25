// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {EthConverter} from "./EthConverter.sol";

error FundMe_Err_NotOwner();

contract FundMe {
    //type declaration
    using EthConverter for uint256;

    //state variables
    address[] private s_funders; // array of funded addresses [0xaaa, 0xbbb, 0xcca]
    mapping(address funder => uint256 amountFunded) private s_funderToAmount;

    uint256 public constant MIN_USD = 5e18; // 5,000,000,000,000,000,000
    address private immutable i_owner; //the address that deployed the contract
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // ================================================================
    // │                    Funds Management                          |
    // ================================================================

    function fund() public payable {
        require((msg.value).convertingDepositedEthToUSD(s_priceFeed) >= MIN_USD, "Didn't send enough eth");
        s_funders.push(msg.sender);
        s_funderToAmount[msg.sender] += msg.value;
    }

    modifier ownerOnly() {
        //  require(msg.sender == i_owner, "Must be owner");
        if (msg.sender != i_owner) {
            revert FundMe_Err_NotOwner();
        }
        _;
    }

    function withdraw() public ownerOnly {
        //    require(msg.sender == i_owner, "must be ownner!!!");

        uint256 fundersLength = s_funders.length;

        for (uint256 index = 0; index < fundersLength; index++) {
            address eachFunder = s_funders[index];

            // deleting mapping records one after the other
            s_funderToAmount[eachFunder] = 0;
        }

        // reset array
        s_funders = new address[](0);

        // three ways to withdraw funds
        //transfer
        // payable(msg.sender).transfer(address(this).balance);

        //send
        //  bool sendSuccess = payable(msg.sender).send(address(this).balance);\
        //  require(sendSucess, "Transaction Failed");

        //call
        (bool sendTransation,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sendTransation, "failed"); // if transaction fails revert
    }

    // -----------------------------------------------------------------------------------------------------

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // GETTERS
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_funderToAmount[fundingAddress];
        // input address and get amount it funded
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
        // input index and get the funding address
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
