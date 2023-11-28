require("@nomiclabs/hardhat-waffle");  // For testing
require("@nomiclabs/hardhat-etherscan"); // For etherscan verification
require("@nomiclabs/hardhat-ethers"); // For ethers.js
require('dotenv').config(); // For .env file
require('@openzeppelin/hardhat-upgrades'); // For upgradeable contracts
require('@nomiclabs/hardhat-etherscan'); // For etherscan verification

console.log(process.env.SEPOLIA_PRIVATE_KEY); // Sepolia private key
console.log(process.env.SEPOLIA_RPC_URL); // Sepolia RPC URL

const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.8.1",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.8.19",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      {
        version: "0.8.20",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
    ],
  },
  networks: {
    hardhat: {
      // Default network when running tests, compile, etc.
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [`0x${SEPOLIA_PRIVATE_KEY}`],
      // Sepolia private key,
      chainId: 11155111,
    },
  },
};
