// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Importing statements for OpenZeppelin's ERC20 standards, utilities and other dependencies as upgrades
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

    // Interface for modular functionality, enabling external modules to execute specific actions
interface IModule {
    function execute(address target, uint256 value, bytes calldata data) external returns (bool, bytes memory);
}

// Using directive for SafeERC20
using SafeERC20Upgradeable for IERC20Upgradeable;

// Contract declaration
// The LikesToken contract, inheriting from various OpenZeppelin contracts for standard ERC20 functionality,
// burnability, pause capability, access control, and reentrancy protection
contract LikesToken is Initializable, ReentrancyGuardUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, AccessControlUpgradeable, OwnableUpgradeable {


        // Initializer for initializing the token with specific attributes TokenName and TokenTicker
    function initialize(address[] memory _recipients, uint256[] memory _amounts) public initializer {
        __Context_init_unchained();
        __ERC20_init_unchained("LikesToken", "LTXO");
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __AccessControl_init_unchained();
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();

    // Defining role constants for access control
    bytes32 public constant GNOSIS_SAFE_ROLE = keccak256(abi.encodePacked("GNOSIS_SAFE_ROLE"));
    bytes32 public constant PRICE_UPDATER_ROLE = keccak256("PRICE_UPDATER_ROLE");
    bytes32 public constant AIRDROPPER_ROLE = keccak256("AIRDROPPER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    // Variables related to price feed and token economics
    AggregatorV3Interface internal priceFeedETHUSD;
    uint256 public tokenPrice; // Price of the token in USD
    uint256 public lastUpdated; // Timestamp of the last price update
    uint256 private constant MAX_SUPPLY = 2006000000 * 10**18; // Maximum supply of the token with 18 decimals
    uint256[50] private __gap; // Reserved storage space to allow for upgrades in the future

    // Mappings for airdrop recipients and allowed modules
    mapping(address => uint256) public airdropRecipients;
    mapping(address => bool) public allowedModules;

    // Events for logging changes and actions
    event PriceUpdated(uint256 newRate);
    event TokensAirdropped(address recipient, uint256 amount);
    event EtherReceived(address indexed sender, uint256 amount);
    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event EtherWithdrawn(address indexed recipient, uint256 amount);
    event ERC20TokensWithdrawn(address indexed recipient, uint256 amount);
    event TokensReceived(address indexed token, address indexed sender, uint256 amount);
    event TokensTransferred(address indexed token, address indexed recipient, uint256 amount);
    event ModuleExecuted(address indexed module, address indexed target, uint256 value, bytes data);
    event ModuleExecutionFailed(address indexed module, address indexed target, uint256 value, bytes data);
    event ModuleApproved(address indexed module);
    event ModuleRevoked(address indexed module);
    event ModulePermissionsSet(address indexed module, bool canExecute);
    event ModulePermissionsRevoked(address indexed module);
    event ModulePermissionsRevokedForAll(bool canExecute);
    event ModulePermissionsSetForAll(bool canExecute);
    event ModulePermissionsSetForAllForAll(bool canExecute);
    event UpgradeInitiated(address indexed implementation, uint256 timestamp);
    event UpgradeFinalized(address indexed implementation);
    event UpgradeCanceled(address indexed implementation);

    // Struct to keep track of airdrop recipients and amounts
    ERC20Upgradeable.__ERC20_init("LikesToken", "LTXO") 
    {

    // Defining role constants for access control
    bytes32 public constant GNOSIS_SAFE_ROLE = keccak256(abi.encodePacked("GNOSIS_SAFE_ROLE"));
    bytes32 public constant PRICE_UPDATER_ROLE = keccak256("PRICE_UPDATER_ROLE");
    bytes32 public constant AIRDROPPER_ROLE = keccak256("AIRDROPPER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    // Variables related to price feed and token economics
    AggregatorV3Interface internal priceFeedETHUSD;
    uint256 public tokenPrice;
    uint256 public lastUpdated;
    uint256 private constant MAX_SUPPLY = 2006000000 * 10**18;

    // Variables related to future upgrades
    address public implementation;
    address public pendingImplementation;
    uint256 public constant UPGRADE_DELAY = 2 days;
    uint256 public upgradeTimestamp;


    // Struct to keep track of airdrop recipients and amounts
    struct AirdropRecipient {
        address user;
        uint256 amount;
    }

    // Array to store airdrop details
    AirdropRecipient[] public airdropList;
    address public gnosisSafe;

    // Modifier to restrict certain functions to only the Gnosis Safe
    modifier onlyGnosisSafe() {
        require(msg.sender == gnosisSafe, "Not authorized");
        _;
    }

        // Check for matching lengths in recipients and amounts arrays
        require(_recipients.length == _amounts.length, "Arrays must be of equal length");

        // Setting Gnosis Safe address
        gnosisSafe = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        // Loop to populate the airdrop list with recipients and their respective amounts
        for (uint256 i = 0; i < _recipients.length; i++) {
            AirdropRecipient memory newRecipient = AirdropRecipient({
                user: _recipients[i],
                amount: _amounts[i]
            });
            airdropList.push(newRecipient);
        }

    // Minting tokens to Gnosis Safe directly
    _mint(gnosisSafe, 2006000000 * 10**decimals());

    // Setting initial token price and last updated timestamp
    lastUpdated = block.timestamp;
    priceFeedETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    updatePrice();

    // Granting the DEFAULT_ADMIN_ROLE to the message sender (typically the deployer of the contract).
    // This role has overarching control and can manage other roles and critical functionalities.
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

    // Granting the PRICE_UPDATER_ROLE to the Gnosis Safe address.
    // This role allows updating the token price, centralizing this sensitive operation.
    _grantRole(PRICE_UPDATER_ROLE, msg.sender);

    // Granting the AIRDROPPER_ROLE to address 1.
    // This role can execute airdrops, enabling the distribution of tokens to multiple addresses.
    _grantRole(AIRDROPPER_ROLE, address.addr1);

    // Granting the MINTER_ROLE to address 2.
    // This role enables the minting of new tokens, controlling the token supply.
    _grantRole(MINTER_ROLE, address.addr2);

    // Granting the MODULE_ADMIN_ROLE to address 3.
    // This role is responsible for managing modular functionalities such as adding or removing modules.
    _grantRole(MODULE_ADMIN_ROLE, address.addr3;

    // Granting the DAO_ROLE to the message sender.
    // This role is responsible for managing the DAO, including voting and governance.
    _grantRole(DAO_ROLE, msg.sender);
    }

    // Overriding the _mint function to add a check for the maximum supply
    // This prevents the minting of tokens beyond the maximum supply
    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        super._mint(account, amount);
    }

    // Function to get the latest ETH/USD price from Chainlink
    // This is used to calculate the token price in USD
    function getLatestETHPriceInUSD() public view returns (uint256) external {
        (, int ethUsdPrice,,,) = priceFeedETHUSD.latestRoundData();
        require(ethUsdPrice > 0, "Invalid price data");
        return uint256(ethUsdPrice);
    }

    // Function to update the token price
    // This can only be called once a day
        function updatePrice() public onlyRole(PRICE_UPDATER_ROLE) nonReentrant {
        require(block.timestamp - lastUpdated > 1 days, "Can only update once a day");
        lastUpdated = block.timestamp;
        uint256 latestPrice = getLatestETHPriceInUSD();  // Get latest ETH/USD price from Chainlink
        tokenPrice = (3 * 1e16) / latestPrice;  // 3 cents in wei based on ETH/USD price feed
        emit PriceUpdated(tokenPrice);
    }

    // Function to purchase tokens
    // This function is payable and can only be called when the contract is not paused
    function purchaseTokens(uint256 numberOfTokens) public payable whenNotPaused nonReentrant {
        require(msg.value == numberOfTokens * tokenPrice, "Amount not correct");
        require(balanceOf(address(this)) >= numberOfTokens, "Not enough tokens left for sale");
        _transfer(address(this), msg.sender, numberOfTokens);
    }

    // Function to mint new tokens
    // This function can only be called by the MINTER_ROLE
    function mint(address recipient, uint256 amount) public onlyRole(MINTER_ROLE) nonReentrant {
        _mint(recipient, amount);
    }

    // Function to pause the contract
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