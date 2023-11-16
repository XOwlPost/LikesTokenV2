const { deployProxy } = require('@openzeppelin/hardhat-upgrades');

async function main() {
    const LikesToken = await ethers.getContractFactory('LikesToken');
    const likesToken = await deployProxy(LikesToken, [args], { initializer: 'initialize' });
    console.log('Deployed at:', likesToken.address);
}
