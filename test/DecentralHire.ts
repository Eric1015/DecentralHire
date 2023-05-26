// SPDX-License-Identifier: MIT License
import { ethers } from 'hardhat';
import { expect } from 'chai';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';

describe('DecentralHire', function () {
  const name = 'Example Company';
  const websiteUrl = 'https://example.com';

  async function setupFixture() {
    const DecentralHire = await ethers.getContractFactory('DecentralHire');
    const decentralHire = await DecentralHire.deploy();

    return { decentralHire };
  }

  it('should create a company profile', async function () {
    const { decentralHire } = await loadFixture(setupFixture);
    const createProfileTx = await decentralHire.createCompanyProfile(
      name,
      websiteUrl
    );
    await createProfileTx.wait();

    expect(createProfileTx)
      .to.emit(decentralHire, 'CompanyProfileCreatedEvent')
      .withArgs(createProfileTx.from, name, websiteUrl);
  });
});
