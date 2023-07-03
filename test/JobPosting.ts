// SPDX-License-Identifier: MIT License
import '@nomicfoundation/hardhat-network-helpers';
import { ethers } from 'hardhat';
import { expect } from 'chai';

import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('JobPosting', function () {
  let owner: SignerWithAddress;
  let developer: SignerWithAddress;
  let companyProfileOwner: SignerWithAddress;
  let applicant: SignerWithAddress;

  async function setupFixture() {
    const accounts = await ethers.getSigners();
    owner = accounts[0];
    developer = accounts[1];
    companyProfileOwner = accounts[2];
    applicant = accounts[3];

    const DecentralHire = await ethers.getContractFactory('DecentralHire');
    const decentralHire = await DecentralHire.deploy();
    const eventEmitterAddress = await decentralHire.getEventEmitterAddress();

    const JobPosting = await ethers.getContractFactory('JobPosting');
    const jobPosting = await JobPosting.deploy(
      developer.address,
      eventEmitterAddress,
      companyProfileOwner.address,
      'Job Title',
      'QmXnYz',
      'Country',
      'City',
      true,
      5
    );

    return { jobPosting };
  }

  describe('applyForJob', function () {
    it('should apply for a job', async function () {
      const { jobPosting } = await loadFixture(setupFixture);

      const resumeCid = 'QmAbCd';

      const createJobApplicationTx = await jobPosting
        .connect(applicant)
        .applyForJob(resumeCid, {
          value: ethers.utils.parseEther('0.001'),
        });

      await createJobApplicationTx.wait();

      const applicationMetadataList = await jobPosting.getReceivedApplications(
        0
      );
      expect(applicationMetadataList.length).to.equal(1);
      expect(applicationMetadataList[0].applicantAddress).to.equal(
        applicant.address
      );

      expect(createJobApplicationTx)
        .to.emit(jobPosting, 'JobApplicationCreatedEvent')
        .withArgs(
          applicant.address,
          applicationMetadataList[0].jobApplicationAddress,
          resumeCid
        );
    });
  });
});
