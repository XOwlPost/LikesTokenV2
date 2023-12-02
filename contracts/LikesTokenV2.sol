// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./LikesToken.sol";

contract LikesTokenV2 is LikesToken {
    bool private _newFeatureActivated;

    // If MAX_SUPPLY needs to change in V2, you will have to manage it differently.
    // For example, using an internal variable and a function to get its value, 
    // which can be overridden in V2.

    function initializeV2() public initializer {
        _newFeatureActivated = false;
    }

    function activateNewFeature() public onlyOwner {
        _newFeatureActivated = true;
    }

    function newFeatureActive() public view returns (bool) {
        return _newFeatureActivated;
    }

    // Additional functions or modifications...
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// ... other imports and contract code ...

contract LikesToken is /* ...inheritance... */ {
    // ... other contract code ...

    uint256 private constant MAX_SUPPLY = 2100 * 10**6 * 10**18; // 21 billion tokens with 18 decimals

    // ... rest of your contract code ...
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LikesToken.sol";

contract LikesTokenV2 is LikesToken {
    bool private _newFeatureActivated;

    function initializeV2() public initializer {
        _newFeatureActivated = false;
    }

    function activateNewFeature() public onlyOwner {
        _newFeatureActivated = true;
    }

    function newFeatureActive() public view returns (bool) {
        return _newFeatureActivated;
    }

contract LikesTokenV2 is LikesToken {
    uint256 private constant MAX_SUPPLY = 2100000000 * 10**18; // 2.1 billion tokens
}
