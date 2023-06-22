// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

contract EventEmitter {
    address public decentralHireAddress;

    constructor(address _decentralHireAddress) {
        decentralHireAddress = _decentralHireAddress;
    }

    event CompanyProfileCreatedEvent(
        address indexed _contractAddress,
        string indexed _name,
        string _websiteUrl
    );

    event JobPostingCreatedEvent(
        address indexed _companyProfileAddress,
        string indexed _title,
        string _country,
        string _city,
        bool _isRemote,
        address _contractAddress
    );

    event JobPostingClosedEvent(
        address indexed _companyProfileAddress,
        address _contractAddress
    );

    event JobApplicationCreatedEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

    event OfferSentEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

    event OfferAcceptedEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

    event OfferDeclinedEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

    event ApplicationDeclinedEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

    event HiredEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

    function isContract(address account) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    modifier onlySenderMatch(address _address) {
        require(
            msg.sender == _address,
            "Only sender address match is allowed to send the event."
        );
        _;
    }

    modifier onlyWhenSenderIsContract(address _address) {
        require(
            isContract(_address),
            "Only contract address is allowed to send the event."
        );
        _;
    }

    function sendCompanyProfileCreatedEvent(
        address _contractAddress,
        string memory _name,
        string memory _websiteUrl
    ) public onlySenderMatch(_contractAddress) {
        emit CompanyProfileCreatedEvent(_contractAddress, _name, _websiteUrl);
    }

    function sendJobPostingCreatedEvent(
        address _companyProfileAddress,
        string memory _title,
        string memory _country,
        string memory _city,
        bool _isRemote,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit JobPostingCreatedEvent(
            _companyProfileAddress,
            _title,
            _country,
            _city,
            _isRemote,
            _contractAddress
        );
    }

    function sendJobPostingClosedEvent(
        address _companyProfileAddress,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit JobPostingClosedEvent(_companyProfileAddress, _contractAddress);
    }

    function sendJobApplicationCreatedEvent(
        address _applicant,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit JobApplicationCreatedEvent(_applicant, _contractAddress);
    }

    function sendOfferSentEvent(
        address _applicant,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit OfferSentEvent(_applicant, _contractAddress);
    }

    function sendOfferAcceptedEvent(
        address _applicant,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit OfferAcceptedEvent(_applicant, _contractAddress);
    }

    function sendOfferDeclinedEvent(
        address _applicant,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit OfferDeclinedEvent(_applicant, _contractAddress);
    }

    function sendApplicationDeclinedEvent(
        address _applicant,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit ApplicationDeclinedEvent(_applicant, _contractAddress);
    }

    function sendHiredEvent(
        address _applicant,
        address _contractAddress
    ) public onlySenderMatch(_contractAddress) {
        emit HiredEvent(_applicant, _contractAddress);
    }
}
