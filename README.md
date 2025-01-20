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
| ![Tokens](screenshots/sdusa-dex-1.png) | ![Swap](screenshots/dusa-dex-2.png) | ![Confirmation](screenshots/dusa-dex-3.png) |
| Currently supported tokens are MAS, WMAS, USDC and WETH | Enter the amount and token you want to swap from | Confirmation after swaping|

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



