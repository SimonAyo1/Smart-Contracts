// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundMe {
    address payable public campaignOwner;
    uint256 public totalFunds;
    mapping(address => uint256) public funders;
    event FundReceived(address funder, uint256 amount);

    constructor() {
        campaignOwner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == campaignOwner, "Only the campaign owner can call this function.");
        _;
    }

    function contribute() external payable {
        require(msg.value > 0, "You need to send some Ether.");
        funders[msg.sender] += msg.value;
        totalFunds += msg.value;
        emit FundReceived(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyOwner {
        require(totalFunds > 0, "No funds available for withdrawal.");
        campaignOwner.transfer(totalFunds);
        totalFunds = 0;
    }

    function getFunderContribution(address funder) external view returns (uint256) {
        return funders[funder];
    }
}
