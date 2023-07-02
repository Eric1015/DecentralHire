// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";
import "./EventEmitter.sol";
import "./Types.sol";

contract JobApplication {
    enum ApplicationStatus {
        InProgress,
        OfferSent,
        OfferAccepted,
        OfferDeclined,
        ApplicationDeclined,
        Hired
    }

    address internal eventEmitterAddress;
    address public applicant;
    address public companyProfileOwner;
    JobPosting public jobPosting;
    string public resumeCid;
    ApplicationStatus public applicationStatus = ApplicationStatus.InProgress;

    constructor(
        address _eventEmitterAddress,
        address _applicant,
        address _jobPosting,
        string memory _resumeCid
    ) {
        eventEmitterAddress = _eventEmitterAddress;
        applicant = _applicant;
        jobPosting = JobPosting(_jobPosting);
        resumeCid = _resumeCid;
        EventEmitter eventEmitter = EventEmitter(_eventEmitterAddress);
        eventEmitter.sendJobApplicationCreatedEvent(
            _applicant,
            address(this),
            _jobPosting
        );
    }

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

    function getJobApplicationMetadata()
        public
        view
        returns (JobApplicationMetadata memory)
    {
        return
            JobApplicationMetadata(
                address(this),
                address(jobPosting),
                applicant,
                companyProfileOwner,
                resumeCid,
                getApplicationStatusString(applicationStatus)
            );
    }

    function onReceiveOffer()
        public
        onlyJobPostingOwner
        onlyWhenApplicationInStatus(ApplicationStatus.InProgress)
    {
        applicationStatus = ApplicationStatus.OfferSent;
        EventEmitter eventEmitter = EventEmitter(eventEmitterAddress);
        eventEmitter.sendOfferSentEvent(
            applicant,
            address(this),
            address(jobPosting)
        );
    }

    function acceptOffer()
        public
        onlyApplicant
        onlyWhenApplicationInStatus(ApplicationStatus.OfferSent)
    {
        applicationStatus = ApplicationStatus.OfferAccepted;
        EventEmitter eventEmitter = EventEmitter(eventEmitterAddress);
        eventEmitter.sendOfferAcceptedEvent(
            applicant,
            address(this),
            address(jobPosting)
        );
    }

    function declineOffer()
        public
        onlyApplicant
        onlyWhenApplicationInStatus(ApplicationStatus.OfferSent)
    {
        applicationStatus = ApplicationStatus.OfferDeclined;
        EventEmitter eventEmitter = EventEmitter(eventEmitterAddress);
        eventEmitter.sendOfferDeclinedEvent(
            applicant,
            address(this),
            address(jobPosting)
        );
    }

    function onReceiveDecline()
        public
        onlyJobPostingOwner
        onlyWhenApplicationInStatus(ApplicationStatus.InProgress)
    {
        applicationStatus = ApplicationStatus.ApplicationDeclined;
        EventEmitter eventEmitter = EventEmitter(eventEmitterAddress);
        eventEmitter.sendApplicationDeclinedEvent(
            applicant,
            address(this),
            address(jobPosting)
        );
    }

    function onReceiveHire()
        public
        onlyJobPostingOwner
        onlyWhenApplicationInStatus(ApplicationStatus.OfferAccepted)
    {
        applicationStatus = ApplicationStatus.Hired;
        EventEmitter eventEmitter = EventEmitter(eventEmitterAddress);
        eventEmitter.sendHiredEvent(
            applicant,
            address(this),
            address(jobPosting)
        );
    }

    fallback() external {}
}
