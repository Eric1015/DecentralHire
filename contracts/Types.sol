// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

struct CompanyProfileMetadata {
    address companyProfileAddress;
    address owner;
    string name;
    string websiteUrl;
    string logoCid;
}

struct JobPostingMetadata {
    address companyProfileAddress;
    address jobPostingAddress;
    address owner;
    string title;
    string jobDescriptionIpfsHash;
    string country;
    string city;
    bool isRemote;
    uint totalHiringCount;
    uint currentHiredCount;
    bool isActive;
}

struct JobApplicationMetadata {
    address jobApplicationAddress;
    address jobPostingAddress;
    address applicantAddress;
    address companyProfileOwner;
    string resumeCid;
    string offerCid;
    string applicationStatus;
}
