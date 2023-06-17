// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";

contract JobApplication {
    enum ApplicationStatus {
        InProgress,
        OfferSent,
        OfferAccepted,
        OfferDeclined,
        ApplicationDeclined,
        Hired
    }

    address public applicant;
    address public companyProfileOwner;
    JobPosting public jobPosting;
    string public resumeCid;
    ApplicationStatus public applicationStatus = ApplicationStatus.InProgress;

    constructor(
        address _applicant,
        address _jobPosting,
        string memory _resumeCid
    ) {
        applicant = _applicant;
        jobPosting = JobPosting(_jobPosting);
        resumeCid = _resumeCid;
    }

    event OfferSentEvent(
        address indexed _applicant,
        address indexed _jobApplication
    );

    event OfferAcceptedEvent(
        address indexed _applicant,
        address indexed _jobApplication
    );

    event OfferDeclinedEvent(
        address indexed _applicant,
        address indexed _jobApplication
    );

    event ApplicationDeclinedEvent(
        address indexed _applicant,
        address indexed _jobApplication
    );

    event HiredEvent(
        address indexed _applicant,
        address indexed _jobApplication
    );

    function getApplicationStatusString(
        ApplicationStatus _status
    ) public pure returns (string memory) {
        if (_status == ApplicationStatus.InProgress) return "InProgress";
        if (_status == ApplicationStatus.OfferSent) return "OfferSent";
        if (_status == ApplicationStatus.OfferAccepted) return "OfferAccepted";
        if (_status == ApplicationStatus.OfferDeclined) return "OfferDeclined";
        if (_status == ApplicationStatus.ApplicationDeclined)
            return "ApplicationDeclined";
        if (_status == ApplicationStatus.Hired) return "Hired";
        revert("Invalid application status");
    }

    modifier onlyApplicant() {
        require(
            msg.sender == applicant,
            "Only applicant is allowed to perform the action."
        );
        _;
    }

    modifier onlyWhenApplicationInStatus(ApplicationStatus _applicationStatus) {
        require(
            applicationStatus == _applicationStatus,
            string.concat(
                "Application needs to be in ",
                getApplicationStatusString(_applicationStatus),
                " status"
            )
        );
        _;
    }

    modifier onlyJobPostingOwner() {
        require(
            msg.sender == address(jobPosting),
            "Only the corresponding job posting can perform the action."
        );
        _;
    }

    function isApplicationActive() public view returns (bool) {
        return
            jobPosting.isActive() &&
            (applicationStatus != ApplicationStatus.ApplicationDeclined ||
                applicationStatus != ApplicationStatus.OfferDeclined ||
                applicationStatus != ApplicationStatus.OfferAccepted);
    }

    function getApplicant() public view returns (address) {
        return applicant;
    }

    function getResume() public view returns (string memory) {
        return resumeCid;
    }

    function getJobPosting() public view returns (address) {
        return address(jobPosting);
    }

    function getCurrentApplicationStatus() public view returns (string memory) {
        return getApplicationStatusString(applicationStatus);
    }

    function onReceiveOffer()
        public
        onlyJobPostingOwner
        onlyWhenApplicationInStatus(ApplicationStatus.InProgress)
    {
        applicationStatus = ApplicationStatus.OfferSent;
        emit OfferSentEvent(applicant, address(this));
    }

    function acceptOffer()
        public
        onlyApplicant
        onlyWhenApplicationInStatus(ApplicationStatus.OfferSent)
    {
        applicationStatus = ApplicationStatus.OfferAccepted;
        emit OfferAcceptedEvent(applicant, address(this));
    }

    function declineOffer()
        public
        onlyApplicant
        onlyWhenApplicationInStatus(ApplicationStatus.OfferSent)
    {
        applicationStatus = ApplicationStatus.OfferDeclined;
        emit OfferDeclinedEvent(applicant, address(this));
    }

    function onReceiveHire()
        public
        onlyJobPostingOwner
        onlyWhenApplicationInStatus(ApplicationStatus.OfferAccepted)
    {
        applicationStatus = ApplicationStatus.Hired;
        emit HiredEvent(applicant, address(this));
    }

    fallback() external {}
}
