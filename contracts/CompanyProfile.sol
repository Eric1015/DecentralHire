// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

contract CompanyProfile {
    address public owner;
    string public name;
    string public websiteUrl;
    mapping(address => address) jobPostings;

    constructor(string memory _name, string memory _websiteUrl) {
        owner = msg.sender;
        name = _name;
        websiteUrl = _websiteUrl;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner is allowed to perform the action."
        );
        _;
    }

    function setCompanyName(string memory _name) public onlyOwner {
        name = _name;
    }

    function setWebsiteUrl(string memory _websiteUrl) public onlyOwner {
        websiteUrl = _websiteUrl;
    }
}
