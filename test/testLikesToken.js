const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LikesToken Contract", function () {
    let owner, addr1, addr2, gnosisSafeMock;
    beforeEach(async function () {
        [owner, addr1, addr2, gnosisSafeMock] = await ethers.getSigners();
    
        // Use addresses from the signers for testing
        const recipients = [addr1.address, addr2.address, gnosisSafeMock.address, owner.address];
        const amounts = ["1000", "2000", "3000", "4000"]; // Ensure correct token amounts
    
        // Deploying the LikesToken contract
        const LikesToken = await ethers.getContractFactory("LikesToken");
        likesToken = await LikesToken.deploy(recipients, amounts);
        await likesToken.deployed();
    
        // Additional setup: Assign roles to gnosisSafeMock
        const GNOSIS_SAFE_ROLE = await likesToken.GNOSIS_SAFE_ROLE(); // Get the role identifier
        await likesToken.grantRole(GNOSIS_SAFE_ROLE, gnosisSafeMock.address); // Grant the role
    });

    it("Should deploy the contract with correct initial configurations", async function () {
        expect(await token.name()).to.equal("LikesToken");
        expect(await token.symbol()).to.equal("LTXO");
        expect(await token.totalSupply()).to.equal(ethers.utils.parseEther("2006000000"));
        expect(await token.balanceOf(gnosisSafe.address)).to.equal(ethers.utils.parseEther("2006000000"));
    });

    it("Should only allow PRICE_UPDATER_ROLE to update the price", async function () {
        await token.connect(priceUpdater).updatePrice();
        await expect(token.connect(addr1).updatePrice()).to.be.revertedWith("AccessControl: account 0x123...456 does not have price updater role 0x123...456");
        contract.connect(account1).updatePrice()
    });

    it("Should allow token purchase", async function () {
        const amountToBuy = ethers.utils.parseEther("1");
        const priceForAmount = (await token.tokenPrice()).mul(amountToBuy);
        await token.connect(addr1).purchaseTokens(amountToBuy, { value: priceForAmount });
        expect(await token.balanceOf(addr1.address)).to.equal(amountToBuy);
    });

    afterEach(async function () {
        // Resetting or cleaning up the state after each test
    });
});

    describe("LikesToken with Mock Gnosis Safe", function () {
        // ... (other test initializations)
    
        it("Should only allow Gnosis Safe to transfer tokens", async function () {
            const tokenAmount = ethers.utils.parseEther("10");
            await token.connect(gnosisSafe).transferTokens(addr1.address, tokenAmount);
            expect(await token.balanceOf(addr1.address)).to.equal(tokenAmount);
            await expect(token.connect(addr1).transferTokens(addr2.address, tokenAmount)).to.be.revertedWith("Not authorized");
        });
    
        it("Should only allow Gnosis Safe to withdraw Ether", async function () {
            const etherAmount = ethers.utils.parseEther("1");
            await owner.sendTransaction({ to: token.address, value: etherAmount });
            expect(await ethers.provider.getBalance(token.address)).to.equal(etherAmount);
            await token.connect(gnosisSafe).withdrawEther(addr1.address);
            expect(await ethers.provider.getBalance(token.address)).to.equal(0);
            await expect(token.connect(addr1).withdrawEther(addr2.address)).to.be.revertedWith("Not authorized");
        });
    
        it("Should only allow Gnosis Safe to withdraw ERC20 Tokens", async function () {
            const anotherTokenFactory = await ethers.getContractFactory("ERC20");
            const anotherToken = await anotherTokenFactory.deploy("Another Token", "ANT");
            const tokenAmount = ethers.utils.parseEther("50");
            await anotherToken.transfer(token.address, tokenAmount);
            expect(await anotherToken.balanceOf(token.address)).to.equal(tokenAmount);
            await token.connect(gnosisSafe).withdrawERC20Tokens(anotherToken.address, addr1.address);
            expect(await anotherToken.balanceOf(token.address)).to.equal(0);
            await expect(token.connect(addr1).withdrawERC20Tokens(anotherToken.address, addr2.address)).to.be.revertedWith("Not authorized");
        });

        afterEach(async function () {
            // Resetting or cleaning up the state after each test
        });
    });

    
        describe("LikesToken with Mock Gnosis Safe - Negative Tests", function () {

            // ... (other test initializations)
        
            it("Should not allow non-Gnosis Safe addresses to transfer tokens", async function () {
                const tokenAmount = ethers.utils.parseEther("10");
                await expect(token.connect(addr1).transferTokens(addr2.address, tokenAmount)).to.be.revertedWith("Not authorized");
            });
        
            it("Should not allow non-Gnosis Safe addresses to withdraw Ether", async function () {
                const etherAmount = ethers.utils.parseEther("1");
                await owner.sendTransaction({ to: token.address, value: etherAmount });
                await expect(token.connect(addr1).withdrawEther(addr2.address)).to.be.revertedWith("Not authorized");
            });
        
            it("Should not allow non-Gnosis Safe addresses to withdraw ERC20 Tokens", async function () {
                const anotherTokenFactory = await ethers.getContractFactory("ERC20");
                const anotherToken = await anotherTokenFactory.deploy("Another Token", "ANT");
                const tokenAmount = ethers.utils.parseEther("50");
                await anotherToken.transfer(token.address, tokenAmount);
                await expect(token.connect(addr1).withdrawERC20Tokens(anotherToken.address, addr2.address)).to.be.revertedWith("Not authorized");
            });
        
            it("Should not allow setting a zero address for Gnosis Safe", async function () {
                await expect(token.setGnosisSafe(ethers.constants.AddressZero)).to.be.revertedWith("Gnosis Safe address cannot be zero address");
            });

            afterEach(async function () {
                // Resetting or cleaning up the state after each test
            });
        });

        
            describe("LikesToken Comprehensive Tests", function () {
                let token, owner, addr1, addr2, addr3, gnosisSafeMock;
                // ... (other test initializations)
                
                beforeEach(async function () {
                    // Deployment and setting up the mock Gnosis Safe address
                    // ... (as before)
            
                    // Provide some tokens to the contract for testing airdrop and sales
                    const initialSupply = ethers.utils.parseEther("1000");
                    await token.transfer(token.address, initialSupply);
                });
            
                // 1. Airdrop Functionality Tests:
                it("Should successfully airdrop tokens", async function () {
                    const airdropAmount = ethers.utils.parseEther("10");
                    await token.addAirdropRecipients([addr1.address], [airdropAmount]);
                    await token.airdrop(0, 1);
                    expect(await token.balanceOf(addr1.address)).to.equal(airdropAmount);
                });
            
                it("Should not allow unauthorized addresses to airdrop tokens", async function () {
                    await expect(token.connect(addr1).airdrop(0, 1)).to.be.revertedWith("AccessControl: account 0x... is missing role 0x...");
                });
            
                // 2. Add/Remove and Execute Module Functionality Tests:
                it("Should successfully add a module", async function () {
                    const dummyModule = addr2.address;
                    await token.addModule(dummyModule);
                    expect(await token.allowedModules(dummyModule)).to.equal(true);
                });
            
                it("Should successfully remove a module", async function () {
                    const dummyModule = addr2.address;
                    await token.addModule(dummyModule);
                    await token.removeModule(dummyModule);
                    expect(await token.allowedModules(dummyModule)).to.equal(false);
                });
            
                // ... (You'd need to deploy a mock module contract to test `executeModule` function)
            
                // 3. Roles Management Tests:
                it("Should successfully grant a role", async function () {
                    await token.grantRole(PRICE_UPDATER_ROLE, addr1.address);
                    expect(await token.hasRole(PRICE_UPDATER_ROLE, addr1.address)).to.equal(true);
                });
            
                it("Should successfully revoke a role", async function () {
                    await token.grantRole(PRICE_UPDATER_ROLE, addr1.address);
                    await token.revokeRole(PRICE_UPDATER_ROLE, addr1.address);
                    expect(await token.hasRole(PRICE_UPDATER_ROLE, addr1.address)).to.equal(false);
                });
            
                // 4. Transfer and Withdraw Tokens and Ether Tests:
                it("Should successfully transfer tokens", async function () {
                    const transferAmount = ethers.utils.parseEther("5");
                    await token.connect(gnosisSafeMock).transferTokens(addr1.address, transferAmount);
                    expect(await token.balanceOf(addr1.address)).to.equal(transferAmount);
                });
            
                it("Should not allow unauthorized addresses to transfer tokens", async function () {
                    const transferAmount = ethers.utils.parseEther("5");
                    await expect(token.connect(addr1).transferTokens(addr1.address, transferAmount)).to.be.revertedWith("Not authorized");
                });
            
                it("Should successfully withdraw Ether", async function () {
                    const etherAmount = ethers.utils.parseEther("1");
                    await owner.sendTransaction({ to: token.address, value: etherAmount });
                    const initialBalance = await ethers.provider.getBalance(addr1.address);
                    await token.connect(gnosisSafeMock).withdrawEther(addr1.address);
                    const finalBalance = await ethers.provider.getBalance(addr1.address);
                    expect(finalBalance.sub(initialBalance)).to.equal(etherAmount);
                });
            
                it("Should not allow unauthorized addresses to withdraw Ether", async function () {
                    const etherAmount = ethers.utils.parseEther("1");
                    await owner.sendTransaction({ to: token.address, value: etherAmount });
                    await expect(token.connect(addr1).withdrawEther(addr1.address)).to.be.revertedWith("Not authorized");
                });
            
               // ... (previous test setup)

// 1. Safe Transfer Test:
it("Should successfully execute safeTransfer", async function () {
    const transferAmount = ethers.utils.parseEther("5");
    await token.approve(token.address, transferAmount);
    await token.receiveTokens(token, transferAmount);  // To provide tokens to contract for testing
    await token.connect(gnosisSafeMock).transferTokens(addr1.address, transferAmount);
    expect(await token.balanceOf(addr1.address)).to.equal(transferAmount);
});

// 2. Non-Reentrancy Test:
it("Should prevent reentrancy attacks", async function () {
    // Deploy a malicious contract that attempts reentrancy
    const ReentrancyAttack = await ethers.getContractFactory("ReentrancyAttack");
    const attack = await ReentrancyAttack.deploy(token.address);
    await attack.deployed();

    // Send some ether to malicious contract
    await owner.sendTransaction({ to: attack.address, value: ethers.utils.parseEther("1") });

    // Expect the reentrancy attack to fail
    await expect(attack.attack()).to.be.reverted;
});

// (The ReentrancyAttack contract would be a separate malicious contract specifically designed to test reentrancy. You'd need to write and deploy it separately.)

// 3. Mint Supply Test:
it("Should not mint more than MAX_SUPPLY", async function () {
    const mintAmount = ethers.utils.parseEther("2006000001");  // One token more than MAX_SUPPLY
    await expect(token.connect(owner).mint(gnosisSafeMock.address, mintAmount)).to.be.revertedWith("Exceeds max supply");
});

it("Should mint tokens within MAX_SUPPLY limit", async function () {
    const mintAmount = ethers.utils.parseEther("100");
    await token.connect(owner).mint(gnosisSafeMock.address, mintAmount);
    expect(await token.balanceOf(gnosisSafeMock.address)).to.equal(mintAmount);
});

// ... (previous test setup)

it("Should add new airdrop recipients", async function() {
    const initialAirdropListLength = (await token.airdropList()).length;

    const newRecipients = [addr1.address, addr2.address];
    const newAmounts = [ethers.utils.parseEther("10"), ethers.utils.parseEther("15")];

    await token.connect(owner).addAirdropRecipients(newRecipients, newAmounts);

    const finalAirdropListLength = (await token.airdropList()).length;
    expect(finalAirdropListLength).to.equal(initialAirdropListLength + 2);

    const addedRecipient1 = await token.airdropList(finalAirdropListLength - 2);
    const addedRecipient2 = await token.airdropList(finalAirdropListLength - 1);

    expect(addedRecipient1.user).to.equal(newRecipients[0]);
    expect(addedRecipient1.amount).to.equal(newAmounts[0]);

    expect(addedRecipient2.user).to.equal(newRecipients[1]);
    expect(addedRecipient2.amount).to.equal(newAmounts[1]);
});

it("Should revert when adding airdrop recipients with mismatched arrays", async function() {
    const newRecipients = [addr1.address, addr2.address];
    const newAmounts = [ethers.utils.parseEther("10")]; // Only one amount provided

    // Expecting the transaction to be reverted with the specified error message
    await expect(
        token.connect(owner).addAirdropRecipients(newRecipients, newAmounts)
    ).to.be.revertedWith("Arrays must be of equal length");

    it("should handle transfers correctly", async function() {
        // Transfer tokens from owner to addr1 and check balances
        await likesToken.connect(owner).transfer(addr1.address, 100);
        expect(await likesToken.balanceOf(addr1.address)).to.equal(100);
    });
    
        it("should only allow Gnosis Safe to update settings", async function() {
            await expect(likesToken.connect(addr1).updateSetting("newSetting")).to.be.revertedWith("Not authorized");
            // Assuming `updateSetting` is restricted to the Gnosis Safe
    });

    afterEach(async function () {
        // Resetting or cleaning up the state after each test
    });


    // End of LikesToken Comprehensive Tests
    // End of LikesToken Comprehensive Tests
    // End of LikesToken with Mock Gnosis Safe - Negative Tests
}); // End of LikesToken with Mock Gnosis Safe
}); // End of LikesToken Comprehensive Tests