/**
 * @title LikesToken
 * @dev ERC20 token with additional features such as burning, pausing, airdropping, and module execution.
 * @dev Tokens are minted to a Gnosis Safe and can be purchased by sending ETH to the contract.
 * @dev The token price is updated daily based on the ETH/USD price feed from Chainlink.
 * @dev Airdrops can be performed to a list of pre-defined recipients.
 * @dev Modules can be added and executed by a Gnosis Safe.
 */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";  // Future-proofing module expansions
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


interface IModule {
    function execute(address target, uint256 value, bytes calldata data) external returns (bool, bytes memory);
}


contract LikesToken is ReentrancyGuard, ERC20, ERC20Burnable, Pausable, AccessControl, Ownable {
    using SafeERC20 for IERC20;

    bytes32 public constant GNOSIS_SAFE_ROLE = keccak256("GNOSIS_SAFE_ROLE");
    bytes32 public constant PRICE_UPDATER_ROLE = keccak256("PRICE_UPDATER_ROLE");
    bytes32 public constant AIRDROPPER_ROLE = keccak256("AIRDROPPER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");

    AggregatorV3Interface internal priceFeedETHUSD;
    uint256 public tokenPrice;
    uint256 public lastUpdated;
    uint256 private constant MAX_SUPPLY = 2006000000 * 10**18;

    mapping(address => uint256) public airdropRecipients;
    mapping(address => bool) public allowedModules;

    event PriceUpdated(uint256 newRate);
    event TokensAirdropped(address recipient, uint256 amount);

    struct AirdropRecipient {
        address user;
        uint256 amount;
    }

    AirdropRecipient[] public airdropList;
    address public gnosisSafe;

    modifier onlyGnosisSafe() {
        require(msg.sender == gnosisSafe, "Not authorized");
        _;
    }

constructor(address[] memory _recipients, uint256[] memory _amounts) 
    ERC20("LikesToken", "LTXO") 
{
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(PRICE_UPDATER_ROLE, msg.sender);
    _grantRole(AIRDROPPER_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
    _grantRole(MODULE_ADMIN_ROLE, msg.sender);
    _grantRole(GNOSIS_SAFE_ROLE, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    Ownable() 
    
        // Recipients array
        const recipients = [
            "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 
            "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", 
            "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", 
            "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
        ];
    
        // Amounts array
        const amounts = ["10000", "20000", "30000", "40000"];
    
{
    require(_recipients.length == _amounts.length, "Arrays must be of equal length");
    
    gnosisSafe = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 /* initialize your Gnosis Safe address here */;

    for (uint256 i = 0; i < _recipients.length; i++) {
        AirdropRecipient memory newRecipient = AirdropRecipient({
            user: _recipients[i],
            amount: _amounts[i]
        });
        airdropList.push(newRecipient);
    }

    // Minting tokens to Gnosis Safe directly
    _mint(gnosisSafe, 2006000000 * 10**decimals());

    lastUpdated = block.timestamp;
    priceFeedETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    updatePrice();

    // Granting the DEFAULT_ADMIN_ROLE to the message sender (typically the deployer of the contract).
    // This role has overarching control and can manage other roles and critical functionalities.
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    // Granting the PRICE_UPDATER_ROLE to the Gnosis Safe address.
    // This role allows updating the token price, centralizing this sensitive operation.
    _grantRole(PRICE_UPDATER_ROLE, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    // Granting the AIRDROPPER_ROLE to the message sender.
    // This role can execute airdrops, enabling the distribution of tokens to multiple addresses.
    _grantRole(AIRDROPPER_ROLE, msg.sender);
    // Granting the MINTER_ROLE to the message sender.
    // This role enables the minting of new tokens, controlling the token supply.
    _grantRole(MINTER_ROLE, msg.sender);
    // Granting the MODULE_ADMIN_ROLE to the message sender.
    // This role is responsible for managing modular functionalities such as adding or removing modules.
    _grantRole(MODULE_ADMIN_ROLE, msg.sender);
    }


    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        super._mint(account, amount);
    }

    function getLatestETHPriceInUSD() public view returns (uint256) {
        (, int ethUsdPrice,,,) = priceFeedETHUSD.latestRoundData();
        require(ethUsdPrice > 0, "Invalid price data");
        return uint256(ethUsdPrice);
    }

    function updatePrice() public onlyRole(PRICE_UPDATER_ROLE) {
        require(block.timestamp - lastUpdated > 1 days, "Can only update once a day");
        lastUpdated = block.timestamp;
        uint256 latestPrice = getLatestETHPriceInUSD();  // Get latest ETH/USD price from Chainlink
        tokenPrice = (3 * 1e16) / latestPrice;  // 3 cents in wei based on ETH/USD price feed
        emit PriceUpdated(tokenPrice);
    }

    function purchaseTokens(uint256 numberOfTokens) public payable whenNotPaused nonReentrant {
        require(msg.value == numberOfTokens * tokenPrice, "Amount not correct");
        require(balanceOf(address(this)) >= numberOfTokens, "Not enough tokens left for sale");
        _transfer(address(this), msg.sender, numberOfTokens);
    }

    function setTokenPrice(uint256 newPrice) public onlyRole(PRICE_UPDATER_ROLE) {
        tokenPrice = newPrice;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function withdrawFunds() public onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }

    function airdrop(uint256 start, uint256 end) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        require(start < end, "Start must be less than end");
        require(end <= airdropList.length, "End is out of bounds");
        require(end - start <= 100, "Can only airdrop to 100 addresses at a time");

        for (uint256 i = start; i < end; i++) {
            _transfer(address(this), airdropList[i].user, airdropList[i].amount * 10**decimals());
            emit TokensAirdropped(airdropList[i].user, airdropList[i].amount);
        }
    }

    function addAirdropRecipients(address[] memory _recipients, uint256[] memory _amounts) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        require(_recipients.length == _amounts.length, "Arrays must be of equal length");

        for (uint256 i = 0; i < _recipients.length; i++) {
            AirdropRecipient memory newRecipient = AirdropRecipient({
                user: _recipients[i],
                amount: _amounts[i]
            });
            airdropList.push(newRecipient);
        }
    }

    function receiveTokens(IERC20 token, uint256 amount) external nonReentrant {
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function transferTokens(IERC20 token, address recipient, uint256 amount) public onlyGnosisSafe nonReentrant {
    token.safeTransfer(recipient, amount);
    }

    function withdrawEther(address payable recipient) external onlyGnosisSafe nonReentrant {
    require(address(this).balance > 0, "No Ether to withdraw");
    recipient.transfer(address(this).balance);
    }

    function withdrawERC20Tokens(IERC20 token, address recipient) external onlyGnosisSafe nonReentrant {
    uint256 balance = token.balanceOf(address(this));
    require(balance > 0, "No tokens to withdraw");
    token.safeTransfer(recipient, balance);
    }

    event EtherReceived(address indexed sender, uint256 amount);
        receive() external payable {
    
        emit EtherReceived(msg.sender, msg.value);
    }

    function addModule(address module) public onlyRole(MODULE_ADMIN_ROLE) {
    require(module != address(0), "Invalid address");
    require(!allowedModules[module], "Module already added");
    allowedModules[module] = true;
    }

    function removeModule(address module) public
     onlyRole(MODULE_ADMIN_ROLE) {
    require(allowedModules[module], "Module not found");
    allowedModules[module] = false;
    }

    function executeModule(address module, address target, uint256 value, bytes calldata data) external onlyGnosisSafe {
    require(allowedModules[module], "Module not allowed");
    IModule(module).execute(target, value, data);
    }
}