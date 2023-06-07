# DecentralHire

This is a blockchain project that makes the hiring process more transparent.


### Commands

```shell
# running the test
npx hardhat test

# deploy the contract
npx hardhat run scripts/deploy.ts
```

For local testing:

```shell
# start the local network
npx hardhat node --network hardhat

# copy one of the private key listed in the accounts and import the account in Metamask for test usage.

# deploy the contract to local network
npx hardhat run scripts/deploy.ts --network localhost
```


### Test Code generation with ChatGPT

```shell
# input the following prompt command to ChatGPT for it to generate the test code for you:

Can you write the hardhat test code for the following solidity smart contract by leveraging loadFixture function from the library "@nomicfoundation/hardhat-network-helpers"?

<Contract file content here>
```


```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
