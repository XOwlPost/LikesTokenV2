// Import the required hardhat functionalities
const hre = require("hardhat");

async function main() {
  // The timestamp for the lock - you would compute this beforehand
  // For example, let's say the release time is for November 2, 2023
  const releaseTime = Math.floor(new Date('2023-11-02T00:00:00Z').getTime() / 1000);

  // The beneficiary address - the account that will receive the tokens after the time lock
  const beneficiary = "0xYourBeneficiaryAddressHere";

  // We get the contract to deploy
  const TokenTimelock = await hre.ethers.getContractFactory("TokenTimelock");
  
  // Deploy the contract with the necessary arguments
  const tokenTimelock = await TokenTimelock.deploy(
    // Here you would pass the address of the ERC20 token contract, 
    // the beneficiary address, and the release time
    "0xYourERC20TokenAddressHere", 
    beneficiary, 
    releaseTime
  );

  // Wait for the contract to be deployed
  await tokenTimelock.deployed();

  console.log(`TokenTimelock deployed to: ${tokenTimelock.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
