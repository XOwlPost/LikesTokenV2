// verifyContracts.js
try {
    // Replace this with the correct path to the contract JSON artifact
    const Contract = require('@openzeppelin/contracts/build/contracts/ERC20.json');
    console.log('OpenZeppelin contract is found:', Contract.contractName);
  } catch (error) {
    console.error('Failed to require OpenZeppelin contract:', error);
  }
