// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobApplication.sol";
import "./EventEmitter.sol";
import "./Types.sol";

contract JobPosting {
    address payable internal developerAddress;
    address internal eventEmitterAddress;
    address public companyProfileAddress;
    address public companyProfileOwner;
    string public title;
    string public jobDescriptionIpfsHash;
    string public country;
    string public city;
    bool public isRemote = false;
    uint public totalHiringCount;
    uint public currentHiredCount = 0;
    bool public isActive = true;
    mapping(address => Hiring) public hiredApplicants;
    address[] public hiredApplicantsArray;
    mapping(address => ApplicationMetadata) public receivedApplications;
    address[] public receivedApplicationsArray;
    string public jobClosingReason;

    constructor(
        address payable _developerAddress,
        address _eventEmitterAddress,
        address _companyProfileOwner,
        string memory _title,
        string memory _jobDescriptionIpfsHash,
        string memory _country,
        string memory _city,
        bool _isRemote,
        uint _totalHiringCount
    ) {
        developerAddress = _developerAddress;
        companyProfileAddress = msg.sender;
        companyProfileOwner = _companyProfileOwner;
        title = _title;
        jobDescriptionIpfsHash = _jobDescriptionIpfsHash;
        country = _country;
        city = _city;
        isRemote = _isRemote;
        totalHiringCount = _totalHiringCount;
        eventEmitterAddress = _eventEmitterAddress;
        EventEmitter eventEmitter = EventEmitter(_eventEmitterAddress);
        eventEmitter.sendJobPostingCreatedEvent(
            msg.sender,
            _title,
            _country,
            _city,
            _isRemote,
            address(this)
        );
    }

    struct Hiring {
        address applicant;
        uint hiredDatetime;
    }

    struct ApplicationMetadata {
        JobApplication jobApplication;
        address jobApplicationAddress;
        bool applied;
    }

    modifier onlyOwner() {
        require(
            msg.sender == companyProfileOwner,
            "Only owner is allowed to perform the action."
        );
        _;
    }

    modifier onlyNotOwner() {
        require(
            msg.sender != companyProfileOwner,
            "Owner is not allowed to perform the action."
        );
        _;
    }

    modifier onlyWhileActive() {
        require(isActive, "Job Posting not active anymore.");
        _;
    }

    modifier onlyWhenNotYetApplied() {
        require(
            receivedApplications[msg.sender].applied == false,
            "Job Posting already applied by the sender."
        );
        _;
    }

    modifier onlyIfSpotAvailable() {
        require(
            currentHiredCount < totalHiringCount,
            "Job Posting already hired to its total hiring count."
        );
        _;
    }

    modifier onlyWhenMinimumFeePaidForApplication() {
        require(
            msg.value >= 0.001 ether,
            "Minimum fee of 0.001 ether is required for applying to this job."
        );
        _;
    }

    modifier onlyWhenApplicantExists(address _applicant) {
        require(
            receivedApplications[_applicant].applied == true,
            "Job Posting not applied by the sender."
        );
        _;
    }

    function getTitle() public view returns (string memory) {
        return title;
    }

    function getJobDescriptionIpfsHash() public view returns (string memory) {
        return jobDescriptionIpfsHash;
    }

    function getCountry() public view returns (string memory) {
        return country;
    }

    function getCity() public view returns (string memory) {
        return city;
    }

    function getIsRemote() public view returns (bool) {
        return isRemote;
    }

    function getTotalHiringCount() public view returns (uint) {
        return totalHiringCount;
    }

    function getCurrentHiredCount() public view returns (uint) {
        return currentHiredCount;
    }

    function getHiredApplicants(
        uint offset
    ) public view returns (Hiring[] memory) {
        uint limit = 100;
        Hiring[] memory array = new Hiring[](limit);
        uint hiredApplicantsArrayIndex = offset;
        uint end = offset + limit > currentHiredCount
            ? currentHiredCount
            : offset + limit;
        for (uint i = offset; i < end; i++) {
            address jobApplicantAddress = hiredApplicantsArray[i];
            if (hiredApplicants[jobApplicantAddress].applicant != address(0)) {
                array[hiredApplicantsArrayIndex] = hiredApplicants[
                    jobApplicantAddress
                ];
                hiredApplicantsArrayIndex++;
            }
        }
        return array;
    }

    function getReceivedApplications(
        uint offset
    ) public view returns (JobApplicationMetadata[] memory) {
        uint limit = 100;
        JobApplicationMetadata[] memory array = new JobApplicationMetadata[](
            limit
        );
        uint receivedApplicationsArrayIndex = offset;
        uint end = offset + limit > currentHiredCount
            ? currentHiredCount
            : offset + limit;
        for (uint i = offset; i < end; i++) {
            address jobApplicantAddress = receivedApplicationsArray[i];
            if (receivedApplications[jobApplicantAddress].applied == true) {
                JobApplication jobApplication = receivedApplications[
                    jobApplicantAddress
                ].jobApplication;
                array[receivedApplicationsArrayIndex] = jobApplication
                    .getJobApplicationMetadata();
                receivedApplicationsArrayIndex++;
            }
        }
        return array;
    }

    function getJobPostingMetadata()
        public
        view
        returns (JobPostingMetadata memory)
    {
        return
            JobPostingMetadata(
                companyProfileAddress,
                address(this),
                companyProfileOwner,
                title,
                jobDescriptionIpfsHash,
                country,
                city,
                isRemote,
                totalHiringCount,
                currentHiredCount,
                isActive
            );
    }

    function setJobPostingMetadata(
        string memory _title,
        string memory _jobDescriptionIpfsHash,
        string memory _country,
        string memory _city,
        bool _isRemote
    ) public onlyOwner onlyWhileActive {
        title = _title;
        jobDescriptionIpfsHash = _jobDescriptionIpfsHash;
        country = _country;
        city = _city;
        isRemote = _isRemote;
    }

    // cost of 0.001 ETH is required to apply for a job
    function applyForJob(
        string memory resumeCid
    )
        public
        payable
        onlyWhileActive
        onlyNotOwner
        onlyWhenNotYetApplied
        onlyWhenMinimumFeePaidForApplication
    {
        JobApplication jobApplication = new JobApplication(
            eventEmitterAddress,
            msg.sender,
            address(this),
            resumeCid
        );
        receivedApplications[msg.sender] = ApplicationMetadata(
            jobApplication,
            address(jobApplication),
            true
        );
        receivedApplicationsArray.push(msg.sender);
        developerAddress.transfer(msg.value);
    }

    function sendOffer(
        address _applicant,
        string memory _offerCid
    ) public onlyOwner onlyWhileActive onlyWhenApplicantExists(_applicant) {
        JobApplication jobApplication = receivedApplications[_applicant]
            .jobApplication;
        jobApplication.onReceiveOffer(_offerCid);
    }

    function decline(
        address _applicant
    ) public onlyOwner onlyWhileActive onlyWhenApplicantExists(_applicant) {
        JobApplication jobApplication = receivedApplications[_applicant]
            .jobApplication;
        jobApplication.onReceiveDecline();
    }

    function hire(
        address _applicant
    ) public onlyOwner onlyIfSpotAvailable onlyWhenApplicantExists(_applicant) {
        JobApplication jobApplication = receivedApplications[_applicant]
            .jobApplication;
        jobApplication.onReceiveHire();
        hiredApplicants[_applicant] = Hiring(_applicant, block.timestamp);
        hiredApplicantsArray.push(_applicant);
        currentHiredCount++;
    }

    function closePosting(
        string memory _reason
    ) public onlyOwner onlyWhileActive {
        jobClosingReason = _reason;
        isActive = false;
        EventEmitter eventEmitter = EventEmitter(eventEmitterAddress);
        eventEmitter.sendJobPostingClosedEvent(
            companyProfileAddress,
            address(this)
        );
    }

    fallback() external {}
}
