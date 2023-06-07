import { HardhatUserConfig, task } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import { config as dotEnvConfig } from 'dotenv';
dotEnvConfig();

const config: HardhatUserConfig = {
  solidity: '0.8.18',
  networks: {
    sepolia: {
      url: process.env.INFURA_URL_SEPOLIA,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY_SEPOLIA || ''],
    },
    hardhat: {
      chainId: 1337,
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 40000,
  },
};

export default config;
