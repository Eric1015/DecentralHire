// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobApplication.sol";

contract JobPosting {
    struct JobPostingMetadata {
        address companyProfileAddress;
        string title;
        string jobDescriptionIpfsHash;
        string country;
        string city;
        bool isRemote;
        uint totalHiringCount;
        uint currentHiredCount;
        bool isActive;
    }

    address payable internal developerAddress;
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
    mapping(address => ApplicationMetadata) public receivedApplications;
    string public jobClosingReason;

    constructor(
        address payable _developerAddress,
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

    event JobApplicationCreatedEvent(
        address indexed _applicant,
        address indexed _contractAddress
    );

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
            "Minimum fee of 0.1 ether is required for applying to this job."
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
        Hiring[] memory hiredApplicantsArray = new Hiring[](limit);
        uint hiredApplicantsArrayIndex = offset;
        uint end = offset + limit > currentHiredCount
            ? currentHiredCount
            : offset + limit;
        for (uint i = offset; i < end; i++) {
            if (hiredApplicants[companyProfileOwner].applicant != address(0)) {
                hiredApplicantsArray[
                    hiredApplicantsArrayIndex
                ] = hiredApplicants[companyProfileOwner];
                hiredApplicantsArrayIndex++;
            }
        }
        return hiredApplicantsArray;
    }

    function getReceivedApplications(
        uint offset
    ) public view returns (JobApplication[] memory) {
        uint limit = 100;
        JobApplication[]
            memory receivedApplicationsArray = new JobApplication[](limit);
        uint receivedApplicationsArrayIndex = offset;
        uint end = offset + limit > currentHiredCount
            ? currentHiredCount
            : offset + limit;
        for (uint i = offset; i < end; i++) {
            if (receivedApplications[companyProfileOwner].applied == true) {
                receivedApplicationsArray[
                    receivedApplicationsArrayIndex
                ] = receivedApplications[companyProfileOwner].jobApplication;
                receivedApplicationsArrayIndex++;
            }
        }
        return receivedApplicationsArray;
    }

    function getJobPostingMetadata()
        public
        view
        returns (JobPostingMetadata memory)
    {
        return
            JobPostingMetadata(
                companyProfileAddress,
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
            msg.sender,
            address(this),
            resumeCid
        );
        receivedApplications[msg.sender] = ApplicationMetadata(
            jobApplication,
            address(jobApplication),
            true
        );
        emit JobApplicationCreatedEvent(msg.sender, address(jobApplication));
        developerAddress.transfer(msg.value);
    }

    function sendOffer(
        address _applicant
    ) public onlyOwner onlyWhileActive onlyWhenApplicantExists(_applicant) {
        JobApplication jobApplication = receivedApplications[_applicant]
            .jobApplication;
        jobApplication.onReceiveOffer();
    }

    function hire(
        address _applicant
    ) public onlyOwner onlyIfSpotAvailable onlyWhenApplicantExists(_applicant) {
        JobApplication jobApplication = receivedApplications[_applicant]
            .jobApplication;
        jobApplication.onReceiveHire();
        hiredApplicants[_applicant] = Hiring(_applicant, block.timestamp);
        currentHiredCount++;
    }

    function closePosting(
        string memory _reason
    ) public onlyOwner onlyWhileActive {
        jobClosingReason = _reason;
        isActive = false;
    }

    fallback() external {}
}
