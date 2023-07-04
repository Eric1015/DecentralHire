// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";
import "./EventEmitter.sol";
import "./Types.sol";

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

    function updateCompanyProfile(
        string memory _name,
        string memory _websiteUrl,
        string memory _logoCid
    ) public onlyOwner {
        name = _name;
        websiteUrl = _websiteUrl;
        logoCid = _logoCid;
    }

    function getCompanyProfileMetadata()
        public
        view
        returns (CompanyProfileMetadata memory)
    {
        return
            CompanyProfileMetadata({
                companyProfileAddress: address(this),
                owner: owner,
                name: name,
                websiteUrl: websiteUrl,
                logoCid: logoCid
            });
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

    function closeJobPosting(
        address _jobPostingAddress,
        string memory _jobClosingReason
    ) public onlyOwner {
        JobPosting jobPosting = JobPosting(_jobPostingAddress);
        jobPosting.closePosting(_jobClosingReason);
        for (uint i = 0; i < activeJobPostingAddresses.length; i++) {
            if (activeJobPostingAddresses[i] == _jobPostingAddress) {
                activeJobPostingAddresses[i] = activeJobPostingAddresses[
                    activeJobPostingAddresses.length - 1
                ];
                activeJobPostingAddresses.pop();
                break;
            }
        }
    }

    function listActiveJobPostings()
        public
        view
        returns (JobPostingMetadata[] memory)
    {
        JobPostingMetadata[]
            memory activeJobPostings = new JobPostingMetadata[](
                activeJobPostingAddresses.length
            );
        for (uint i = 0; i < activeJobPostingAddresses.length; i++) {
            if (jobPostings[activeJobPostingAddresses[i]].isActive()) {
                JobPosting jobPosting = JobPosting(
                    activeJobPostingAddresses[i]
                );
                activeJobPostings[i] = jobPosting.getJobPostingMetadata();
            }
        }
        return activeJobPostings;
    }

    fallback() external {}
}
