// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

import "./JobPosting.sol";

contract JobApplication {
    enum ApplicationStatus {
        PendingReview,
        InReview,
        Interviewing,
        OfferSent,
        OfferAccepted,
        OfferDeclined,
        ApplicationDeclined
    }

    address public applicant;
    JobPosting public jobPosting;
    ApplicationStatus public applicationStatus =
        ApplicationStatus.PendingReview;

    constructor(address _jobPosting) {
        applicant = msg.sender;
        jobPosting = JobPosting(_jobPosting);
    }

    function getApplicationStatusString(
        ApplicationStatus _status
    ) public pure returns (string memory) {
        if (_status == ApplicationStatus.PendingReview) return "PendingReview";
        if (_status == ApplicationStatus.InReview) return "InReview";
        if (_status == ApplicationStatus.Interviewing) return "Interviewing";
        if (_status == ApplicationStatus.OfferSent) return "OfferSent";
        if (_status == ApplicationStatus.OfferAccepted) return "OfferAccepted";
        if (_status == ApplicationStatus.OfferDeclined) return "OfferDeclined";
        if (_status == ApplicationStatus.ApplicationDeclined)
            return "ApplicationDeclined";
        revert("Invalid application status");
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
}
