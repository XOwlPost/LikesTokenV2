const ethers = require('ethers');

// Replace these with the actual role names from your contract
const roleNames = ['GNOSIS_SAFE_ROLE', 'PRICE_UPDATER_ROLE', 'AIRDROPPER_ROLE', 'MINTER_ROLE', 'MODULE_ADMIN_ROLE'];

roleNames.forEach(roleName => {
  const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(roleName));
  console.log(`${roleName}: ${hash}`);
});