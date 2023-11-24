// RewardsDistributor.sol

Manages the distribution of staking rewards inlcuding airdrops or other incentives.

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./LikesToken.sol";  // Import the LikesToken contract

contract RewardsDistributor is AccessControlUpgradeable {
    LikesToken public likesToken;  // Reference to the LikesToken contract

    // Define events
    event AirdropRecipientMarked(address recipient);
    event AirdropListReset();

    constructor(address _likesTokenAddress) {
        likesToken = LikesToken(_likesTokenAddress);
    }

    function markAirdropRecipients(address[] memory recipients) external onlyRole(AIRDROPPER_ROLE) {
        for (uint256 i = 0; i < recipients.length; i++) {
            // Call function in LikesToken to mark recipient
            likesToken.markAirdropRecipient(recipients[i]);
            emit AirdropRecipientMarked(recipients[i]);
        }
    }

    function resetAirdropList() external onlyRole(AIRDROPPER_ROLE) {
        // Call function in LikesToken to reset airdrop list
        likesToken.resetAirdropList();
        emit AirdropListReset();
    }
}

Integrating the `RewardsDistributor` module with the `LikesToken` core contract involves more than just inheritance. Since Solidity contracts are isolated by default, establishing a link between them for direct communication requires specific strategies. Here are a few approaches you could use:

### 1. **Contract Interface**
- **Interface Use**: Create an interface of `LikesToken` with the necessary function signatures. The `RewardsDistributor` contract can then use this interface to interact with the `LikesToken` contract.
- **Initialization**: Pass the address of the deployed `LikesToken` contract to the `RewardsDistributor` during its initialization or via a setter function.

    ```solidity
    interface ILikesToken {
        function markAirdropRecipient(address recipient) external;
        function resetAirdropList() external;
        // other function signatures
    }

    contract RewardsDistributor {
        ILikesToken public likesToken;

        constructor(address _likesTokenAddress) {
            likesToken = ILikesToken(_likesTokenAddress);
        }

        // Rest of the contract
    }
    ```

### 2. **Direct Contract Calls**
- **Direct Interaction**: If `LikesToken` and `RewardsDistributor` are deployed, you can make direct calls from one contract to another using the address and ABI of the target contract.
- **Address Passing**: Ensure the `RewardsDistributor` knows the address of the `LikesToken` contract, either through the constructor or a setter function.

### 3. **Inheritance (Limited Use)**
- **Inheritance Strategy**: In some cases, contracts can inherit from others, but this is typically used when extending functionality, not for module integration in a decentralized application.
- **Module Independence**: In a modular system, each module should be independent and interact through well-defined interfaces rather than direct inheritance, promoting flexibility and upgradability.

### 4. **Event Listeners (Indirect Integration)**
- **Emitting Events**: Contracts can emit events that other parts of your application (like off-chain services or other contracts) can listen to and react upon.
- **Decoupled Integration**: This approach is more indirect, as it doesn't involve direct contract-to-contract calls but rather a reaction to events in a more decoupled architecture.

### Key Considerations
- **Security and Permissions**: Ensure that only authorized addresses (like the contract or specific roles) can call sensitive functions in the `LikesToken` contract from `RewardsDistributor`.
- **Gas Efficiency**: Direct contract calls can be gas-efficient but require careful management of contract dependencies and updates.
- **Upgradability and Maintenance**: Consider how changes in one contract will affect others, especially in upgradeable contracts.

### Example Code for Setter Function in `RewardsDistributor`
```solidity
contract RewardsDistributor {
    ILikesToken public likesToken;

    function setLikesTokenAddress(address _likesTokenAddress) external onlyOwner {
        likesToken = ILikesToken(_likesTokenAddress);
    }

    // Rest of the contract
}
```
This setter function allows the `RewardsDistributor` contract to update the address of the `LikesToken` contract if necessary, providing flexibility in case of upgrades or changes in the `LikesToken` contract.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RewardsDistributor is Context, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using Counters for Counters.Counter;

    // Roles
    bytes32 public constant AIRDROPPER_ROLE = keccak256("AIRDROPPER_ROLE");

    // Events
    event AirdropRecipientsAdded(address[] recipients, uint256[] amounts);
    event AirdropRecipientMarked(address recipient);
    event AirdropListReset();

    // Structs
    struct AirdropRecipient {
        address recipient;
        uint256 amount;
    }

    // Variables
    Counters.Counter private _airdropIdTracker;
    mapping(address => uint256) public airdropRecipients;
    AirdropRecipient[] public airdropList;

    // Constructor
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(AIRDROPPER_ROLE, _msgSender());
        _setupRole(REWARDS_DISTRIBUTOR_ROLE, _msgSender());
        _setupRole(GNOSIS_SAFE_ROLE, _msgSender());
        _setupRole(SECURITY_ADMIN_ROLE, _msgSender());
    }

    // Access to the necessary data, such as the list of airdrop recipients. This might involve passing data between contracts or shared storage patterns.

    // Function to get the next airdrop id
    // This function can only be called by the AIRDROPPER_ROLE
    function getNextAirdropId() external view returns (uint256) {
        return _airdropIdTracker.current();
        event AirdropIdTrackerUpdated(_airdropIdTracker.current());
        emit AirdropIdTrackerUpdated(_airdropIdTracker.current());
    }

    // Function to get the airdrop recipient list length
    function getAirdropListLength() external view returns (uint256) {
        return airdropList.length;
        event AirdropListLengthUpdated(airdropList.length);
        emit AirdropListLengthUpdated(airdropList.length);
    }

    // Function to get the airdrop recipient list
    function getAirdropList() external view returns (AirdropRecipient[] memory) {
        return airdropList;
        event AirdropListUpdated(airdropList);
        emit AirdropListUpdated(airdropList);
    }

    // Function to get the airdrop recipient amount
    function getAirdropRecipientAmount(address recipient) external view returns (uint256) {
        return airdropRecipients[recipient];
        event AirdropRecipientAmountUpdated(airdropRecipients[recipient]);
        emit AirdropRecipientAmountUpdated(airdropRecipients[recipient]);
    }

    // Passing data between contracts and shared storage patterns
    // The airdrop recipient list is stored in the RewardsDistributor contract. The LikesToken contract can access the list by calling the getAirdropList function.
    function getAirdropList() external view returns (AirdropRecipient[] memory) {
        return airdropList;
    }


    // Function to add airdrop recipients
    // This function can only be called by the AIRDROPPER_ROLE
    function addAirdropRecipients(address[] memory _recipients, uint256[] memory _amounts) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        require(_recipients.length == _amounts.length, "Invalid input");
        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Invalid recipient");
            require(_amounts[i] > 0, "Invalid amount");
            airdropRecipients[_recipients[i]] = _amounts[i];
            airdropList.push(AirdropRecipient(_recipients[i], _amounts[i]));
        }
        emit AirdropRecipientsAdded(_recipients, _amounts);
    }

    // Function to mark recipients who have already received their airdrop
    // This function can only be called by the AIRDROPPER_ROLE
    function markAirdropRecipients(address[] memory recipients) external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        for (uint256 i = 0; i < recipients.length; i++) {
            airdropRecipients[recipients[i]] = 0;
            event AirdropRecipientMarked(recipients[i]);
        emit AirdropRecipientsAdded(_recipients, _amounts);
        }
    }

    // Function to manual reset the airdrop recipient list clearing all recipients and marking them as not airdropped
    // This function can only be called by the AIRDROPPER_ROLE
    function resetAirdropList() external onlyRole(AIRDROPPER_ROLE) nonReentrant {
        delete airdropList;
            airdropList = new AirdropRecipient[](0);
            event AirdropListReset();
        emit AirdropListReset();
    }