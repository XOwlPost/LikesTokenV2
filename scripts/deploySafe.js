const { ethers } = require("hardhat");
const { GnosisSafe } = require("@gnosis.pm/safe-core-sdk");
const { EthersAdapter } = require("@gnosis.pm/safe-ethers-lib");
const { SafeFactory } = require("@gnosis.pm/safe-core-sdk");

async function deploy() {
  const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
  const signer = provider.getSigner();

  // Set up the ethers adapter
  const ethAdapter = new EthersAdapter({
    ethers,
    signer
  });

  // Set up the Safe factory
  const safeFactory = await SafeFactory.create({ ethAdapter });

  // Define the owners of the Gnosis Safe and the number of required confirmations.
  const owners = [await signer.getAddress()];
  const threshold = 1; // For testing purposes, we set the threshold to 1.

  // Deploy the Gnosis Safe
  const safeSdk = await safeFactory.deploySafe({ owners, threshold });
  console.log("GnosisSafe contract deployed at:", safeSdk.getAddress());

  // The rest of your deployment script
  // For example, deploy the LikesToken using the Safe
  const LikesToken = await ethers.getContractFactory("LikesToken");
  const likesTokenData = LikesToken.getDeployTransaction(
    ethers.utils.parseEther("1000000"),
    "LikesToken",
    "LTXO"
  );

  // Create a Safe transaction
  const safeTransaction = await safeSdk.createTransaction({
    to: LikesToken.address,
    value: '0',
    data: likesTokenData.data,
  });

  // Sign the transaction with the off-chain signatures
  await safeSdk.signTransaction(safeTransaction);

  // Execute the transaction
  const executeTxResponse = await safeSdk.executeTransaction(safeTransaction);
  const receipt = await executeTxResponse.transactionResponse.wait();

  console.log(`LikesToken deployed at: ${receipt.contractAddress}`);
}

deploy().catch((error) => {
  console.error(error);
  process.exit(1);
});