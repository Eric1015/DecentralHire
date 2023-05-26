// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./CompanyProfile.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DecentralHire {
    event CompanyProfileCreatedEvent(
        address indexed _from,
        string indexed _name,
        string _websiteUrl
    );

    function createCompanyProfile(
        string memory _name,
        string memory _websiteUrl
    ) public {
        new CompanyProfile(_name, _websiteUrl);
        emit CompanyProfileCreatedEvent(msg.sender, _name, _websiteUrl);
    }
}
