// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.12;

contract JobPosting {
    address public owner;
    uint public totalHiringCount;
    uint public currentHiredCount = 0;
    bool public isActive = true;
    mapping(address => Hiring) public hiredApplicants;
    mapping(address => address) public receivedApplications;

    constructor(uint _totalHiringCount) {
        owner = msg.sender;
        totalHiringCount = _totalHiringCount;
    }

    struct Hiring {
        address applicant;
        uint hiredDatetime;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner is allowed to perform the action."
        );
        _;
    }

    modifier onlyWhileActive() {
        require(isActive, "Job Posting not active anymore.");
        _;
    }

    modifier onlyIfSpotAvailable() {
        require(
            currentHiredCount < totalHiringCount,
            "Job Posting already hired to its total hiring count."
        );
        _;
    }

    function hire(address _applicant) public onlyOwner onlyIfSpotAvailable {
        hiredApplicants[_applicant] = Hiring(_applicant, block.timestamp);
        currentHiredCount++;
    }

    function closePosting() public onlyOwner onlyWhileActive {
        isActive = false;
    }
}
