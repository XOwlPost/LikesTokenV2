it("should correctly interact with a DEX", async function () {
    // Deploy the mock DEX
    const MockDEX = await ethers.getContractFactory("MockDEX");
    const mockDEX = await MockDEX.deploy();
    await mockDEX.deployed();

    // Simulate adding liquidity to the DEX
    const tokenAmount = ethers.utils.parseEther("200");
    const ethAmount = ethers.utils.parseEther("1");
    await likesToken.approve(mockDEX.address, tokenAmount);
    await mockDEX.addLiquidity(likesToken.address, tokenAmount, { value: ethAmount });

    // Simulate swapping tokens
    await mockDEX.swap(likesToken.address, ethers.utils.parseEther("100"));

    // Validate the outcome
    const finalTokenBalance = await likesToken.balanceOf(deployer.address);
    const finalEthBalance = await ethers.provider.getBalance(deployer.address);
    expect(finalTokenBalance).to.be.below(tokenAmount);
    expect(finalEthBalance).to.be.above(0); // Assuming some ETH was received from the swap
});
