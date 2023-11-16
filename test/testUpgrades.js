const { deployProxy } = require('@openzeppelin/hardhat-upgrades');

async function main() {
    const Contract = await ethers.getContractFactory("MyContract");
    const instance = await deployProxy(Contract, [arg1, arg2], { initializer: 'initialize' });
    console.log('Deployed to:', instance.address);
}

main();
