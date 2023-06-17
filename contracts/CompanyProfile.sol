// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";

contract CompanyProfile {
    address payable internal developerAddress;
    address public owner;
    string public name;
    string public websiteUrl;
    mapping(address => JobPosting) jobPostings;
    address[] public activeJobPostingAddresses;
    address public decentralHireAddress;

    event JobPostingCreatedEvent(
        address indexed _from,
        string indexed _companyName,
        string indexed _title,
        string _country,
        string _city,
        bool _isRemote,
        address _contractAddress
    );

    constructor(
        address payable _developerAddress,
        address _owner,
        string memory _name,
        string memory _websiteUrl
    ) {
        developerAddress = _developerAddress;
        owner = _owner;
        decentralHireAddress = msg.sender;
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

    modifier onlyWhenMinimumFeePaidForPosting() {
        require(
            msg.value >= 0.01 ether,
            "Minimum fee of 0.01 ether is required to post a job."
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

    // cost of 0.01 ETH is required to post a job
    function createJobPosting(
        string memory _title,
        string memory _jobDescriptionIpfsHash,
        string memory _country,
        string memory _city,
        bool _isRemote,
        uint _totalHiringCount
    ) public payable onlyOwner onlyWhenMinimumFeePaidForPosting {
        JobPosting jobPosting = new JobPosting(
            developerAddress,
            owner,
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
        developerAddress.transfer(msg.value);
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

    fallback() external {}
}
