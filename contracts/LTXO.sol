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
    event ModuleAdded(address indexed module);
}

// Using directive for SafeERC20
using SafeERC20Upgradeable for IERC20Upgradeable;

// Contract declaration
// The LikesToken contract, inheriting from various OpenZeppelin contracts for standard ERC20 functionality,
// burnability, pause capability, access control, reentrancy protection and upgradability
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
        emit OwnershipTransferred(address(0), msg.sender);
        
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

    // Mappings for airdrop recipients and allowed modules
    mapping(address => uint256) public airdropRecipients;
    mapping(address => bool) public allowedModules;

    // Events for logging changes and actions
    event ModuleExecuted(address indexed module, address indexed target, uint256 value, bytes data);
    event PriceUpdated(uint256 newRate);
    event AirdropRecipientsAdded(address[] recipients, uint256[] amounts);
    event TokensAirdropped(address recipient, uint256 amount);
    event ModuleExecuted(address indexed module, address indexed target, uint256 value, bytes data);
    event EtherWithdrawn(address indexed recipient, uint256 amount);
    event TokensReceived(address indexed token, address indexed sender, uint256 amount);
    event TokensTransferred(address indexed token, address indexed recipient, uint256 amount);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);
    event TokensMinted(address indexed recipient, uint256 amount);
    event TokensBurned(address indexed recipient, uint256 amount);

    // Struct to keep track of airdrop recipients and amounts
    ERC20Upgradeable.__ERC20_init("LikesToken", "LTXO") 
    {

    // Defining role constants for access control
    bytes32 public constant GNOSIS_SAFE_ROLE = keccak256(abi.encodePacked("GNOSIS_SAFE_ROLE"));
    bytes32 public constant PRICE_UPDATER_ROLE = keccak256(abi.encodePacked("PRICE_UPDATER_ROLE");
    bytes32 public constant AIRDROPPER_ROLE = keccak256(abi.encodePacked("AIRDROPPER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256(abi.encodePacked("MINTER_ROLE");
    bytes32 public constant MODULE_ADMIN_ROLE = keccak256(abi.encodePacked("MODULE_ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256(abi.encodePacked("DAO_ROLE");
    bytes32 public constant REWARDS_DISTRIBUTOR_ROLE = keccak256(abi.encodePacked("REWARDS_DISTRIBUTOR_ROLE");
    

    // Variables related to price feed and token economics
    AggregatorV3Interface internal priceFeedETHUSD;
    uint256 public tokenPrice;
    uint256 public lastUpdated;
    uint256 private constant MAX_SUPPLY = 2006000000 * 10**18;

    // Variables related to future upgrades
    uint256[50] private __gap; // Reserved storage space to allow for upgrades in the future

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
            emit AirdropRecipientsAdded(_recipients, _amounts);
        }

    // Setting initial token price and last updated timestamp
    lastUpdated = block.timestamp;
    priceFeedETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    updatePrice();
    emit PriceUpdated(tokenPrice);

    // Granting the DEFAULT_ADMIN_ROLE to the message sender (typically the deployer of the contract).
    // This role has overarching control and can manage other roles and critical functionalities.
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender) onlyGnosisSafe nonReentrant {;
    require (msg.sender == gnosisSafe, "Not authorized");
    emit RoleGranted(DEFAULT_ADMIN_ROLE, msg.sender, msg.sender);
    }

    // Granting the PRICE_UPDATER_ROLE to the Gnosis Safe address.
    // This role allows updating the token price, centralizing this sensitive operation.
    _grantRole(PRICE_UPDATER_ROLE, msg.sender) onlyGnosisSafe nonReentrant {;
    require(msg.sender == gnosisSafe, "Not authorized");
    emit RoleGranted(PRICE_UPDATER_ROLE, msg.sender, msg.sender);
    }

    // Granting the AIRDROPPER_ROLE to address 1.
    // This role can execute airdrops, enabling the distribution of tokens to multiple addresses.
    _grantRole(AIRDROPPER_ROLE, address.addr1) onlyRole AIRDROPPER_ROLE nonReentrant {;
    require(address.addr1 == airdropRecipients[address.addr1], "Not a valid recipient");
    emit RoleGranted(AIRDROPPER_ROLE, address.addr1, msg.sender);
    }

    // Granting the MINTER_ROLE to address 2.
    // This role enables the minting of new tokens, controlling the token supply.
    _grantRole(MINTER_ROLE, address.addr2) onlyRole(MINTER_ROLE_ROLE) nonReentrant {;
    require(airdropRecipients[address.arrays] > 0, "Not a valid recipient")
    emit RoleGranted(MINTER_ROLE, address.addr2, msg.sender);
    }

    // Granting the MODULE_ADMIN_ROLE to address 3.
    // This role is responsible for managing modular functionalities such as adding or removing modules.
    _grantRole(MODULE_ADMIN_ROLE, address.addr3) onlyRole MODULE_ADMIN_ROLE nonReentrant {;
    require(msg.sender == gnosisSafe, "Not authorized");
    emit RoleGranted(MODULE_ADMIN_ROLE, address.addr3, msg.sender);
    }

    // Granting the DAO_ROLE to the message sender.
    // This role is responsible for managing the DAO, including voting and governance.
    _grantRole(DAO_ROLE, msg.sender)onlyGnosisSafe nonReentrant {
        require(msg.sender == gnosisSafe, "Not authorized");
        emit RoleGranted(DAO_ROLE, msg.sender, msg.sender);
    }

    // Granting the REWARDS_DISTRIBUTOR_ROLE to the message sender.
    // This role is responsible for distributing rewards to users.
    _grantRole(REWARDS_DISTRIBUTOR_ROLE, msg.sender) onlyGnosisSafe nonReentrant {
        require(msg.sender == gnosisSafe, "Not authorized");
        emit RoleGranted(REWARDS_DISTRIBUTOR_ROLE, msg.sender, msg.sender);
    }

// Mint 25% of MAX_SUPPLY to the deployer or a specified address
// This is done to ensure that the deployer has enough tokens for liquidity and sales purposes and to execute v1-airdrops
uint256 initialSupply = MAX_SUPPLY / 4; // 25%
_mint(msg.sender, initialSupply);
require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
super._mint(account, amount);
emit TokensMinted(account, amount);
}

    // Overriding the _mint function to add a check for the maximum supply
    // This prevents the minting of tokens beyond the maximum supply
    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        super._mint(account, amount);
        emit TokensMinted(account, amount);
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
        require(balanceOf(address(this)) >= numberOfTokens, "Not enough tokens left in current batch for sale");
        _transfer(address(this), msg.sender, numberOfTokens);
        emit TokensPurchased(msg.sender, numberOfTokens);
    }

    // Function to distribute rewards
    // This function can only be called by the DAO_ROLE
    function distributeRewards(address[] memory recipients, uint256[] memory amounts) public onlyRole(DAO_ROLE) nonReentrant {
        require(recipients.length == amounts.length, "Arrays must be of equal length");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(address(this), recipients[i], amounts[i]);
            emit RewardsDistributed(address(this), recipients[i], amounts[i]);
        }
    }

    // Function to burn tokens
    // This function can only be called by the DAO_ROLE
    function burn(uint256 amount) private onlyRole(DAO_ROLE) nonReentrant {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    // Function to pause the contract
    // This function can only be called by the DEFAULT_ADMIN_ROLE
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
        emit Paused(msg.sender);
    }

    // Function to unpause the contract
    // This function can only be called by the DEFAULT_ADMIN_ROLE
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
        emit Unpaused(msg.sender);
    }

    // Function to airdrop tokens to a list of recipients
    // This function can only be called by the AIRDROPPER_ROLE
    function airdropTokens(address[] memory recipients) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        for (uint256 i = 0; i < recipients.length; i++) {
            require(airdropRecipients[recipients[i]] > 0, "Recipient not found");
            _transfer(address(this), recipients[i], airdropRecipients[recipients[i]]);
            emit TokensAirdropped(recipients[i], airdropRecipients[recipients[i]]);
        }
    }

    // Event for logging received ether
        event EtherReceived(address indexed sender, uint256 amount);
        receive() external payable {

        emit EtherReceived(msg.sender, msg.value);
    }

    // Function to withdraw funds from the contract
    // This function can only be called by the DEFAULT_ADMIN_ROLE
    function withdrawFunds() external onlyGnosisSafe nonReentrant {
    uint256 balance = address(this).balance;
    require(balance > 0, "No funds to withdraw");

    (bool success, ) = payable(owner()).call{value: balance}("");
    require(success, "Transfer failed");

    emit EtherWithdrawn(owner(), balance);
}

    // Function to receive ERC20 tokens
    function receiveTokens(IERC20 token, uint256 amount) external nonReentrant {
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit TokensReceived(address(token), msg.sender, amount);
    }

    // Function to transfer ERC20 tokens
    // This function can only be called by the DEFAULT_ADMIN_ROLE
    function transferTokens(IERC20 token, address recipient, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        token.safeTransfer(recipient, amount);
        emit TokensTransferred(address(token), recipient, amount);
    }

    // Function to add a module
    // This function can only be called by the MODULE_ADMIN_ROLE
    function addModule(address module) public onlyRole(MODULE_ADMIN_ROLE) {
        require(module != address(0), "Invalid address");
        require(!allowedModules[module], "Module already added");
        allowedModules[module] = true;
        emit ModuleAdded(module);
    }

    // Function to remove a module
    // This function can only be called by the MODULE_ADMIN_ROLE
    function removeModule(address module) public onlyRole(MODULE_ADMIN_ROLE) {
        require(allowedModules[module], "Module not found");
        allowedModules[module] = false;
        emit ModuleRemoved(module);
    }

    // Function to airdrop tokens to a list of recipients
    // This function can only be called by the AIRDROPPER_ROLE
    function airdrop(uint256 start, uint256 end) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        require(start < end, "Start must be less than end");
        require(end <= airdropList.length, "End is out of bounds");
        require(end - start <= 100, "Can only airdrop to 100 addresses at a time");

        // Loop to airdrop tokens to a list of recipients
        for (uint256 i = start; i < end; i++) {
            _transfer(address(this), airdropList[i].user, airdropList[i].amount * 10**decimals());
            emit TokensAirdropped(airdropList[i].user, airdropList[i].amount);
        }
    }

    // Function to airdrop tokens to a list of recipients
    // This function can only be called by the AIRDROPPER_ROLE
    function addAirdropRecipients(address[] memory _recipients, uint256[] memory _amounts) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        require(_recipients.length == _amounts.length, "Arrays must be of equal length");

        // Loop to populate the airdrop list with recipients and their respective amounts
            for (uint256 i = 0; i < _recipients.length; i++) {
            AirdropRecipient memory newRecipient = AirdropRecipient({
                user: _recipients[i],
                amount: _amounts[i]
            });
            airdropList.push(newRecipient);
        }
        emit AirdropRecipientsAdded(_recipients, _amounts);
    }

    // Function to execute a module
    // This function can only be called by the Gnosis Safe
    function executeModule(address module, address target, uint256 value, bytes calldata data) external onlyGnosisSafe {
    require(allowedModules[module], "Module not allowed");
    IModule(module).execute(target, value, data);
    emit ModuleExecuted(module, target, value, data);
    }
}