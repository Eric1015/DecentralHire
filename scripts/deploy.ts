// SPDX-License-Identifier: MIT License
import { ethers } from 'hardhat';
import '@nomiclabs/hardhat-ethers';

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Account balance:', (await deployer.getBalance()).toString());

  const DecentralHire = await ethers.getContractFactory('DecentralHire');
  const decentralHire = await DecentralHire.deploy();

  await decentralHire.deployed();

  console.log(`DecentralHire deployed to ${decentralHire.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
