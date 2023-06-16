// SPDX-License-Identifier: MIT License
import { ethers } from 'hardhat';
import { expect } from 'chai';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('CompanyProfile', function () {
  const name = 'Example Company';
  const websiteUrl = 'https://example.com';
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let developer: SignerWithAddress;
  let JobPosting: any;

  async function setupFixture() {
    [owner, addr1, developer] = await ethers.getSigners();
    const CompanyProfile = await ethers.getContractFactory(
      'CompanyProfile',
      owner
    );
    JobPosting = await ethers.getContractFactory('JobPosting');
    const companyProfile = await CompanyProfile.deploy(
      developer.address,
      owner.address,
      '',
      ''
    );

    return { companyProfile };
  }

  it('should have correct initial values', async function () {
    const { companyProfile } = await loadFixture(setupFixture);
    expect(await companyProfile.getCompanyName()).to.equal('');
    expect(await companyProfile.getWebsiteUrl()).to.equal('');
  });

  it('should allow the owner to update the company name', async function () {
    const { companyProfile } = await loadFixture(setupFixture);
    await companyProfile.setCompanyName(name);

    expect(await companyProfile.getCompanyName()).to.equal(name);
  });

  it('should revert when non-owner tries to update company name', async function () {
    const nonOwner = addr1;

    const { companyProfile } = await loadFixture(setupFixture);
    await expect(
      companyProfile.connect(nonOwner).setCompanyName(name)
    ).to.be.revertedWith('Only owner is allowed to perform the action.');

    expect(await companyProfile.getCompanyName()).to.equal('');
  });

  it('should allow the owner to update the website URL', async function () {
    const { companyProfile } = await loadFixture(setupFixture);
    await companyProfile.setWebsiteUrl(websiteUrl);

    expect(await companyProfile.getWebsiteUrl()).to.equal(websiteUrl);
  });

  it('should revert when non-owner tries to update the website URL', async function () {
    const nonOwner = addr1;

    const { companyProfile } = await loadFixture(setupFixture);
    await expect(
      companyProfile.connect(nonOwner).setWebsiteUrl(websiteUrl)
    ).to.be.revertedWith('Only owner is allowed to perform the action.');

    expect(await companyProfile.getWebsiteUrl()).to.equal('');
  });

  it('should create a job posting', async function () {
    const title = 'Software Engineer';
    const jobDescriptionIpfsHash =
      'QmTjDxLoFhqW5G45eZDhswH3wSPx8zeHH2Fyju1pKxZYdE';
    const country = 'United States';
    const city = 'San Francisco';
    const isRemote = false;
    const totalHiringCount = 5;
    const { companyProfile } = await loadFixture(setupFixture);
    const createJobPostingTx = await companyProfile.createJobPosting(
      title,
      jobDescriptionIpfsHash,
      country,
      city,
      isRemote,
      totalHiringCount,
      {
        value: ethers.utils.parseEther('0.01'),
      }
    );
    await createJobPostingTx.wait();

    expect(createJobPostingTx)
      .to.emit(companyProfile, 'JobPostingCreatedEvent')
      .withArgs(createJobPostingTx.from);
  });

  it('should revert when non-owner tries to create a job posting', async function () {
    const nonOwner = addr1;

    const title = 'Software Engineer';
    const jobDescriptionIpfsHash =
      'QmTjDxLoFhqW5G45eZDhswH3wSPx8zeHH2Fyju1pKxZYdE';
    const country = '';
    const city = '';
    const isRemote = true;
    const totalHiringCount = 5;

    const { companyProfile } = await loadFixture(setupFixture);
    await expect(
      companyProfile
        .connect(nonOwner)
        .createJobPosting(
          title,
          jobDescriptionIpfsHash,
          country,
          city,
          isRemote,
          totalHiringCount
        )
    ).to.be.revertedWith('Only owner is allowed to perform the action.');

    const activeJobPostings = await companyProfile.listActiveJobPostings();

    expect(activeJobPostings.length).to.equal(0);
  });
});
