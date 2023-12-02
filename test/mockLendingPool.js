it("should correctly interact with a lending pool", async function () {
    // Deploy the mock lending pool
    const MockLendingPool = await ethers.getContractFactory("MockLendingPool");
    const mockLendingPool = await MockLendingPool.deploy();
    await mockLendingPool.deployed();

    // Simulate depositing tokens into the lending pool
    const depositAmount = ethers.utils.parseEther("100");
    await likesToken.approve(mockLendingPool.address, depositAmount);
    await mockLendingPool.deposit(likesToken.address, depositAmount);

    // ...simulate passage of time for interest accrual...
    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    await hre.network.provider.send("evm_setNextBlockTimestamp", [
        currentTimestampInSeconds + 60,
    ]);

    // Simulate withdrawal from the lending pool
    await mockLendingPool.withdraw(likesToken.address, depositAmount);

    // Validate the final state
    const finalBalance = await likesToken.balanceOf(deployer.address);
    expect(finalBalance).to.be.at.least(depositAmount);
    
    // Further checks for interest, etc.
    const finalBalance = await likesToken.balanceOf(deployer.address);
    expect(finalBalance).to.be.at.least(depositAmount);
}


});
