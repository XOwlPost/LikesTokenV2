const { ethers } = require("ethers");
const { GnosisSafeFactory } = require("@gnosis.pm/safe-contracts");

async function deploy() {
    const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
    const signer = provider.getSigner();
  
    const factory = new GnosisSafeFactory(signer);
    const gnosisSafe = await factory.deploy();
  
    console.log("GnosisSafe contract deployed at:", gnosisSafe.address);
  }
  
  deploy();
  
