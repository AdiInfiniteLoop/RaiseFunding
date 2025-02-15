// SPDX-License-Identifier:MIT
// SPDX-Lincense-Identifier : MIT

//get funds from user
// add funds to owner
//min fund

pragma solidity ^0.8.18;

import {PriceConvertor} from "./PriceConvertor.sol";

contract RaiseFund {
    using PriceConvertor for uint256;
    //It works by attaching functions from the PriceConvertor library to the uint256 type,
    //allowing you to call them as if they were methods of uint256.
    address[] funders;

    mapping(address funder => uint256 amountFunded) public addressToFunds;
    uint256 minUsd = 5e18;

    address public owner;
    constructor() {
        owner = msg.sender;
    } //immediately called when contract iss deployed

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= minUsd,
            "Send atleast the minimum amount"
        );
        // same as PriceConvertor.getConversionRate(msg.value);
        funders.push(msg.sender);
        addressToFunds[msg.sender] = addressToFunds[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        //start index, ending index, step amount
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToFunds[funder] = 0;
        }
        //reset array
        funders = new address[](0); //clear the funders from the funders[]

        //To send the data -> 3 ways ->
        //transfer(2300, throws error)
        payable(msg.sender).transfer(address(this).balance);
        //send(2300, boolean)
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Withdraw failed");
        //call(boolean, data when returned)
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Withdraw failed");
    }

    //Modifier -> maybe similar to a middleware
    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized");
        _; //execute the rest of the code
    }
}
