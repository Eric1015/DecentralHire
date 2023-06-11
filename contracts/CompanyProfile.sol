// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";

contract CompanyProfile {
    address public owner;
    string public name;
    string public websiteUrl;
    mapping(address => JobPosting) jobPostings;
    address[] public activeJobPostingAddresses;

    event JobPostingCreatedEvent(
        address indexed _from,
        string indexed _companyName,
        string indexed _title,
        string _country,
        string _city,
        bool _isRemote,
        address _contractAddress
    );

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

    function getCompanyName() public view returns (string memory) {
        return name;
    }

    function getWebsiteUrl() public view returns (string memory) {
        return websiteUrl;
    }

    function setCompanyName(string memory _name) public onlyOwner {
        name = _name;
    }

    function setWebsiteUrl(string memory _websiteUrl) public onlyOwner {
        websiteUrl = _websiteUrl;
    }

    function createJobPosting(
        string memory _title,
        string memory _jobDescriptionIpfsHash,
        string memory _country,
        string memory _city,
        bool _isRemote,
        uint _totalHiringCount
    ) public onlyOwner {
        JobPosting jobPosting = new JobPosting(
            _title,
            _jobDescriptionIpfsHash,
            _country,
            _city,
            _isRemote,
            _totalHiringCount
        );
        jobPostings[address(jobPosting)] = jobPosting;
        activeJobPostingAddresses.push(address(jobPosting));
        emit JobPostingCreatedEvent(
            msg.sender,
            name,
            _title,
            _country,
            _city,
            _isRemote,
            address(jobPosting)
        );
    }

    function listActiveJobPostings() public view returns (JobPosting[] memory) {
        JobPosting[] memory activeJobPostings = new JobPosting[](
            activeJobPostingAddresses.length
        );
        for (uint i = 0; i < activeJobPostingAddresses.length; i++) {
            if (jobPostings[activeJobPostingAddresses[i]].isActive()) {
                activeJobPostings[i] = jobPostings[
                    activeJobPostingAddresses[i]
                ];
            }
        }
        return activeJobPostings;
    }
}
