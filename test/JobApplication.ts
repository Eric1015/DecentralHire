// SPDX-License-Identifier: MIT License
import '@nomicfoundation/hardhat-network-helpers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { ethers } from 'hardhat';
import { expect } from 'chai';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';

describe('JobApplication', function () {
  let applicant: SignerWithAddress;
  let developer: SignerWithAddress;
  let companyProfileOwner: SignerWithAddress;
  const resumeCid = 'QmAbCd';

  async function setupFixture() {
    const accounts = await ethers.getSigners();
    applicant = accounts[0];
    developer = accounts[1];
    companyProfileOwner = accounts[2];

    // Deploy JobPosting contract
    const JobPosting = await ethers.getContractFactory('JobPosting');
    const jobPosting = await JobPosting.deploy(
      developer.address,
      companyProfileOwner.address,
      'Job Title',
      'QmXnYz',
      'Country',
      'City',
      true,
      5
    );

    // Deploy JobApplication contract
    const JobApplication = await ethers.getContractFactory('JobApplication');
    const jobApplication = await JobApplication.deploy(
      applicant.address,
      jobPosting.address,
      resumeCid
    );

    return {
      jobPosting,
      jobApplication,
    };
  }

  it('should initialize the contract correctly', async function () {
    const { jobApplication, jobPosting } = await loadFixture(setupFixture);
    expect(await jobApplication.getApplicant()).to.equal(applicant.address);
    expect(await jobApplication.getJobPosting()).to.equal(jobPosting.address);
    expect(await jobApplication.getResume()).to.equal(resumeCid);
    expect(await jobApplication.getCurrentApplicationStatus()).to.equal(
      'InProgress'
    );
  });

  // it('should emit OfferSentEvent when receiving an offer', async function () {
  //   const { jobApplication, jobPosting } = await loadFixture(setupFixture);

  //   const receiveOfferTx = await jobApplication
  //     .connect(jobPosting.provider)
  //     .onReceiveOffer();
  //   await receiveOfferTx.wait();

  //   expect(receiveOfferTx)
  //     .to.emit(jobApplication, 'OfferSentEvent')
  //     .withArgs(applicant.address, jobApplication.address);

  //   expect(await jobApplication.getCurrentApplicationStatus()).to.equal(
  //     'OfferSent'
  //   );
  // });

  // it('should emit OfferAcceptedEvent when accepting an offer', async function () {
  //   const { jobApplication } = await loadFixture(setupFixture);

  //   await jobApplication.onReceiveOffer();
  //   const acceptOfferTx = await jobApplication.acceptOffer();
  //   await acceptOfferTx.wait();

  //   expect(acceptOfferTx)
  //     .to.emit(jobApplication, 'OfferAcceptedEvent')
  //     .withArgs(applicant.address, jobApplication.address);

  //   expect(await jobApplication.getCurrentApplicationStatus()).to.equal(
  //     'OfferAccepted'
  //   );
  // });

  // it('should emit OfferDeclinedEvent when declining an offer', async function () {
  //   const { jobApplication } = await loadFixture(setupFixture);

  //   await jobApplication.onReceiveOffer();
  //   const declineOfferTx = await jobApplication.declineOffer();
  //   await declineOfferTx.wait();

  //   expect(declineOfferTx)
  //     .to.emit(jobApplication, 'OfferDeclinedEvent')
  //     .withArgs(applicant.address, jobApplication.address);

  //   expect(await jobApplication.getCurrentApplicationStatus()).to.equal(
  //     'OfferDeclined'
  //   );
  // });

  // it('should emit HiredEvent when receiving a hire notification', async function () {
  //   const { jobApplication } = await loadFixture(setupFixture);

  //   await jobApplication.onReceiveOffer();
  //   await jobApplication.acceptOffer();
  //   const receiveHireTx = await jobApplication.onReceiveHire();
  //   await receiveHireTx.wait();

  //   expect(receiveHireTx)
  //     .to.emit(jobApplication, 'HiredEvent')
  //     .withArgs(applicant.address, jobApplication.address);

  //   expect(await jobApplication.getCurrentApplicationStatus()).to.equal(
  //     'Hired'
  //   );
  // });
});
