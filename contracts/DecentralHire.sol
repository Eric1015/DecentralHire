// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./CompanyProfile.sol";
import "./EventEmitter.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DecentralHire {
    struct CompanyProfileMetadata {
        address companyProfileAddress;
        bool exists;
    }

    address internal eventEmitterAddress;
    address payable internal developerAddress;
    mapping(address => CompanyProfileMetadata) companyProfileOwnerToContractAddress;

    constructor() {
        developerAddress = payable(msg.sender);
        EventEmitter eventEmitter = new EventEmitter(address(this));
        eventEmitterAddress = address(eventEmitter);
    }

    modifier noExistingCompanyProfileForSender() {
        require(
            !isCompanyProfileByOwnerAddressExists(msg.sender),
            "Company profile with the sender address already exists"
        );
        _;
    }

    function createCompanyProfile(
        string memory _name,
        string memory _websiteUrl,
        string memory _logoCid
    ) public noExistingCompanyProfileForSender {
        CompanyProfile companyProfile = new CompanyProfile(
            developerAddress,
            eventEmitterAddress,
            msg.sender,
            _name,
            _websiteUrl,
            _logoCid
        );
        companyProfileOwnerToContractAddress[
            msg.sender
        ] = CompanyProfileMetadata(address(companyProfile), true);
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

    function getEventEmitterAddress() public view returns (address) {
        return eventEmitterAddress;
    }

    fallback() external {}
}
