// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./CompanyProfile.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DecentralHire {
    struct CompanyProfileMetadata {
        address companyProfileAddress;
        bool exists;
    }

    mapping(address => CompanyProfileMetadata) companyProfileOwnerToContractAddress;

    event CompanyProfileCreatedEvent(
        address indexed _from,
        string indexed _name,
        string _websiteUrl,
        address _contractAddress
    );

    modifier noExistingCompanyProfileForSender() {
        require(
            !isCompanyProfileByOwnerAddressExists(msg.sender),
            "Company profile with the sender address already exists"
        );
        _;
    }

    function createCompanyProfile(
        string memory _name,
        string memory _websiteUrl
    ) public noExistingCompanyProfileForSender {
        CompanyProfile companyProfile = new CompanyProfile(_name, _websiteUrl);
        companyProfileOwnerToContractAddress[
            msg.sender
        ] = CompanyProfileMetadata(address(companyProfile), true);
        emit CompanyProfileCreatedEvent(
            msg.sender,
            _name,
            _websiteUrl,
            address(companyProfile)
        );
    }

    function getCompanyProfileByOwner(
        address _address
    ) public view returns (address) {
        return
            companyProfileOwnerToContractAddress[_address]
                .companyProfileAddress;
    }

    function isCompanyProfileByOwnerAddressExists(
        address _address
    ) public view returns (bool) {
        return companyProfileOwnerToContractAddress[_address].exists;
    }

    event EtherReceived(address sender, uint256 value);

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);

        // Additional code for handling the received Ether
    }

    fallback() external {}
}
