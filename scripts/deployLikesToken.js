const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  const initialSupply = hre.ethers.utils.parseEther("1000000");
  const tokenName = "LikesToken";
  const tokenSymbol = "LTXO";

  // Get the contract factory for LikesToken
  const LikesToken = await hre.ethers.getContractFactory("LikesToken");
  const provider = hre.ethers.provider;
  // Deploy the contract with the necessary arguments
  const likesToken = await LikesToken.deploy(
    initialSupply,
    tokenName,
    tokenSymbol
  );

  // Wait for the contract to be deployed
  await likesToken.deployed();

  console.log(`LikesToken deployed to: ${likesToken.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

