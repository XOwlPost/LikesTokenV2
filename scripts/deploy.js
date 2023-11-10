// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { ethers } = require("ethers");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  const amountInEther = "1.00000000000"; // Always use strings for ether amounts to avoid precision issues

  // Use HRE's ethers to parse the amount into wei
  const lockedAmount = hre.ethers.utils.parseEther(amountInEther);

  // Get the contract factory and deploy
  const Lock = await hre.ethers.getContractFactory("Lock");
  const lock = await TokenTimeLock.deploy(unlockTime, { value: lockedAmount });

  // Wait for the contract to be deployed
  await lock.deployed();

  console.log(
    `Lock with ${hre.ethers.utils.formatEther(
      lockedAmount
    )} ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});