# MicroGate (μG)
[![pub.dev][pub-dev-shield]][pub-dev-url]
[![Stars][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

## Introduction
Massa Universal Mobile Gateway, abbreviated as (MUG) and hence resulting in the name microgateway -  abbreviated at (μG), is a universal mobile gatway for Massa Blockchain.

## Features
MicroGate will initally have the following features:

### Massa Wallet
- Massa wallet  - with ability to create multiple wallets, restore wallet from private key, export wallet, send and receive transactions.
### Dusa DEX
- Dusa Integration - with ability to wrap Massa tokens, swap token between MAS and USDC, swap token between MASSA and WETH.
### Massa Explore
- Massa explorer - with ability to list all massa addresses, search for an address, and view address details.


## Development Status
### Massa wallet
- [x] Create wallet
- [x] Store wallet in secure storage
- [x] View wallet details
- [x] Restore wallet from private key
- [x] Export wallet private key and as QR code
- [x] Send transaction from one address to another
- [x] Receive transaction
### Dusa Dex
- [x] Wrap MAS to WMAS
- [x] Unwrap WMAS to MAS
- [x] Swap MAS to USDC.e
- [x] Swap USDC.e to MAS
- [x] Swap MAS to WETH
- [x] Swap WETH to MAS
### Massa explorer
- [x] List all staking addreses
- [x] Search for an address
- [x] View address details
- [x] Search for domain name
- [x] View  domain name details
- [x] Search for operation
- [x] View  view operation details
- [x] Search for block
- [x] View  view block details


## Usage Instructions

### Initial setup and login

Follow these steps to complete the initial setup:

| Step 1: Passphrase setup | Step 2: Login | Step 3: Wallet homepage |
|---|---|---|
| ![Initial Screen](screenshots/passphrase-login-1.png) | ![Login](screenshots/passphrase-login-2.png) | ![Wallet](screenshots/passphrase-login-3.png) |
| Enter your passphrase and its confirmation| Enter passphrase to login. | The default wallet account is created and displyed on wallet homepage |

### MASA Wallet - Import and create wallet

Follow these steps to import an existing wallet or create a new one:

| Step 1: Import wallet | Step 2: Create wallet | Step 3: Wallet homepage |
|---|---|---|
| ![Initial Screen](screenshots/import-create-wallet-1.png) | ![Login](screenshots/import-create-wallet-2.png) | ![Wallet](screenshots/import-create-wallet-3.png) |
| Paste the wallet private key. The imported wallet key is encrypted and added to the list of wallets| Create New wallet, creates a new wallet and store it securely | The second wallet in the lis is imported and the third one is created|

### MASA Wallet - Wallet Details

Follow these steps to view more information about your wallet:

| Step 1: Wallet Tokens | Step 2: Wallet Transactions | Step 3: Wallet Settings |
|---|---|---|
| ![Tokens](screenshots/wallet-details-1.png) | ![Transactions](screenshots/wallet-details-2.png) | ![Settings](screenshots/wallet-details-1.png) |
| List of tokens associated with the wallet | List of transactions | Wallet settings where you can edit wallet name, show the wallet private key and set the wallet as default wallet|

### MASA Wallet - Send and Receive coins

Follow these steps to to send and receive tokens:

| Step 1: Transfer MAS | Step 2: Transaction Confirmation | Step 3: Receive MAS|
|---|---|---|
| ![Send](screenshots/send-receive-1.png) | ![Confirmation](screenshots/send-receive-2.png) | ![Receive](screenshots/send-receive-3.png) |
| Past the recipent address or select from the list of addresses and enter the amount you want to transfer | This is a summary of the transaction | You can scan the address to receive to receive token|


### Dusa DEX - Swap tokens

Follow these steps to to swap tokens using dusa decentralised exchange:

| Step 1: List of tokens | Step 2: Transaction Confirmation | Step 3: Receive MAS|
|---|---|---|
| ![Tokens](screenshots/dusa-dex-1.png) | ![Swap](screenshots/dusa-dex-2.png) | ![Confirmation](screenshots/dusa-dex-3.png) |
| Currently supported tokens are MAS, WMAS, USDC and WETH | Enter the amount and token you want to swap from | Confirmation after swaping|

### Massa Explorer - Search Address

Follow these steps to search for the address:

| Step 1: Explorer Homepage| Step 2: Search Address | Step 3: Address details|
|---|---|---|
| ![Explorer](screenshots/explorer.png) | ![Search Address](screenshots/explorer-address-1.png) | ![Address details](screenshots/explorer-address-2.png) |
| Explorer homepage with search bar| Search an address | View details of the searched address|

### Massa Explorer - Search Block

Follow these steps to search for block using block hash:

| Step 1: Explorer Homepage| Step 2: Search Block | Step 3: Block details|
|---|---|---|
| ![Explorer](screenshots/explorer.png) | ![Search Block](screenshots/explorer-block-1.png) | ![Block details](screenshots/explorer-block-2.png) |
| Explorer homepage with search bar| Search a block with block hash | View details of the searched block|

### Massa Explorer - Search Operation

Follow these steps to search for an operation using the operation hash:

| Step 1: Explorer Homepage| Step 2: Search Operation | Step 3: Operation details|
|---|---|---|
| ![Explorer](screenshots/explorer.png) | ![Search Operation](screenshots/explorer-operation-1.png) | ![Operation details](screenshots/explorer-operation-2.png) |
| Explorer homepage with search bar| Search an operation using operation hash | View details of an operation|

### Massa Explorer - Search Domain

Follow these steps to search for a domain name:

| Step 1: Explorer Homepage| Step 2: Search Domain | Step 3: Domain details|
|---|---|---|
| ![Explorer](screenshots/explorer.png) | ![Search Domain](screenshots/explorer-domain-1.png) | ![Domain details](screenshots/explorer-domain-2.png) |
| Explorer homepage with search bar| Search a domain name. A domain name must end with .massa, e.g `deweb.massa` | View details of a domain name|

If the domain is not found, it likely that it is not yet purchase and you can purchase and own it. Follow these steps to purchase a domain.

| Step 1: Search for domain| Step 2: Search Domain | Step 3: Domain details|
|---|---|---|
| ![Search domain](screenshots/explorer-buy-domain-1.png) | ![Ssearch Status](screenshots/explorer-buy-domain-2.png) | ![Domain purchase confirmation](screenshots/explorer-buy-domain-3.png) |
| Search for the damain| Shows the details of the doamin that does not exist, e.g `ilovemassa.massa`. Click `Buy` to purchase it | Domain purchase confirmation|

### Others

This app supports other functionalies as detailed below:

| Login attempts| Timeout | Settings|
|---|---|---|
| ![Login attempts](screenshots/others-1.png) | ![Timeout](screenshots/others-2.png) | ![Settings](screenshots/others-3.png) |
| The app restricts the number of login attempts to 3. If exceeded, it will disable the apply for a certain duration before it allows you to login again| The app will automatically logout you out for a certain duration of inactivity | The app has settings provision|

## Additional information
You can get more information about massa by visiting the links below.
### Links
- [Massa: Massa main website](https://massa.net)
- [Massa Foundation website](https://massa.foundation)
- [Massa buildnet](https://buildnet.massa.net)
- [Massa station](https://station.massa.net/)
- [Massa Documentation: Valuable massa documentation](https://docs.massa.net/)
- [Massa Github: Massa official github repository](https://github.com/massalabs)
- [Massa Web3: massa-dart will have similar functionalities as massa-web3](https://github.com/massalabs/massa-web3)
- [Massa Dart SDK repository](https://github.com/nafsilabs/massa-dart)
- [Massa Dart SDK documentation](https://pub.dev/documentation/massa/latest/massa/massa-library.html)

### Support
This project is supported by [Massa Foundation Grant](https://massa.foundation)

### Contribute
You can contribute to this package, request new features or report any bug by visiting the package repository at [mug](https://github.com/nafsilabs/mug)


## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[pub-dev-shield]: https://img.shields.io/pub/v/massa?style=for-the-badge
[pub-dev-url]: https://pub.dev/packages/massa
[stars-shield]: https://img.shields.io/github/stars/nafsilabs/mug.svg?style=for-the-badge&logo=github&colorB=deeppink&label=stars
[stars-url]: https://packagist.org/packages/nafsilabs/mug
[issues-shield]: https://img.shields.io/github/issues/nafsilabs/mug.svg?style=for-the-badge
[issues-url]: https://github.com/nafsilabs/mug/issues
[license-shield]: https://img.shields.io/github/license/nafsilabs/mug.svg?style=for-the-badge
[license-url]: https://github.com/nafsilabs/mug/blob/main/LICENSE



