require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0"
      },
      {
        version: "0.8.1"
      },
      {
        version: "0.8.19"
      }
      
    ]
  },
  paths: {
    sources: "./contracts",
    artifacts: "./artifacts",
      "chainlink/contracts": "./link/chainlink/contracts" // path to Chainlink contracts
},
    }
  networks: {
    hardhat: {
      // Default network when running tests, compile, etc.
    }
    localhost: {
      url: "http://127.0.0.1:8545"
    }
      }