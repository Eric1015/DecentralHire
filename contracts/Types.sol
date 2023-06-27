// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

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