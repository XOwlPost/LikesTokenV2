const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LikesToken Contract Deployment", function () {
    let likesToken;
    let owner, addr1, addr2, gnosisSafeMock;

    beforeEach(async function () {
        // Destructuring to get the signers
        [owner, addr1, addr2, gnosisSafeMock] = await ethers.getSigners();

        // Define recipients and amounts for initial airdrop in deployment
        const RECIPIENTS = [
            "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
            "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
            "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
            "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
        ];
        const AMOUNTS = ["1000", "2000", "3000", "4000"];

        // Deploying the LikesToken contract
        const LikesTokenFactory = await ethers.getContractFactory("LikesToken");
        likesToken = await LikesTokenFactory.deploy(RECIPIENTS, AMOUNTS);
        await likesToken.deployed();

        // Assigning the PRICE_UPDATER_ROLE to the owner
        const priceUpdaterRole = await likesToken.PRICE_UPDATER_ROLE();
        await likesToken.grantRole(priceUpdaterRole, owner.address);
    });

    it("Should deploy with correct name, symbol, total supply, and Gnosis Safe balance", async function () {
        const expectedTotalSupply = ethers.utils.parseEther("2006000000");
        const expectedGnosisSafeBalance = expectedTotalSupply;

        expect(await likesToken.name()).to.equal("LikesToken");
        expect(await likesToken.symbol()).to.equal("LTXO");
        expect(await likesToken.totalSupply()).to.equal(expectedTotalSupply);
        expect(await likesToken.balanceOf(gnosisSafeMock.address)).to.equal(expectedGnosisSafeBalance);
    });

    // Add afterEach hook here if necessary for cleanup
});
