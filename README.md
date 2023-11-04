---

# LikesTokenV2

LikesTokenV2 is an enhanced ERC20 token contract with a rich set of features, designed to offer more than just basic token transactions. The contract incorporates various roles and functionalities to provide a comprehensive utility for its users and administrators.

## Features

- **Standard ERC20 Functions**: Supports all standard ERC20 functionalities including minting and burning.
  
- **Role-Based Access Control**: Integrated roles for administrative tasks, price updating, minting, and airdropping.

- **Price Feed**: Leverages Chainlink's AggregatorV3Interface to fetch the latest ETH/USD price, allowing dynamic token pricing.

- **Airdropping**: Built-in airdrop mechanism to distribute tokens to a list of recipients. New recipients can be easily added.

- **Token and Ether Management**: Capable of receiving, holding, and transferring both ERC20 tokens and Ether.

- **Modular Architecture**: Ability to add and execute external modules, offering extended functionalities.

- **Pause and Unpause**: Provides an option to pause and unpause token transfers, enhancing administrative control.

## Roles

- **Price Updater**: Responsible for updating the token price based on the ETH/USD price feed.

- **Airdropper**: Manages the list of airdrop recipients and initiates airdrops.

- **Minter**: Authorized to mint new tokens within the contract's max supply limit.

- **Module Admin**: Manages the external modules that can be executed by the contract. 

## License

This project is licensed under the MIT License.

---