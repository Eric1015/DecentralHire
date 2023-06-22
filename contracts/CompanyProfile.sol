// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";
import "./EventEmitter.sol";

contract CompanyProfile {
    address payable internal developerAddress;
    address internal eventEmitterAddress;
    address public owner;
    string public name;
    string public websiteUrl;
    string public logoCid;
    mapping(address => JobPosting) jobPostings;
    address[] public activeJobPostingAddresses;
    address public decentralHireAddress;

    constructor(
        address payable _developerAddress,
        address _eventEmitterAddress,
        address _owner,
        string memory _name,
        string memory _websiteUrl,
        string memory _logoCid
    ) {
        developerAddress = _developerAddress;
        owner = _owner;
        decentralHireAddress = msg.sender;
        name = _name;
        websiteUrl = _websiteUrl;
        logoCid = _logoCid;
        eventEmitterAddress = _eventEmitterAddress;
        EventEmitter eventEmitter = EventEmitter(_eventEmitterAddress);
        eventEmitter.sendCompanyProfileCreatedEvent(
            address(this),
            _name,
            _websiteUrl
        );
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

    function getLogoCid() public view returns (string memory) {
        return logoCid;
    }

    function setCompanyName(string memory _name) public onlyOwner {
        name = _name;
    }

    function setWebsiteUrl(string memory _websiteUrl) public onlyOwner {
        websiteUrl = _websiteUrl;
    }

    function setLogoCid(string memory _logoCid) public onlyOwner {
        logoCid = _logoCid;
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
            eventEmitterAddress,
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
