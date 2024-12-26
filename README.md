# Solana Web3 Wallet

NTV Forritun 1. Önn 2024 - Lokaverkefni 
Birkir Reynisson


<img src="https://github.com/user-attachments/assets/5cf4b7d5-de15-4b9d-aac5-dea7a8a64652" width="180" alt="Screenshot of demo running on Devnet in android emulator">


## Features

### Core Functionality
- Create new wallet (private key generation)
- Use a Demo wallet with a saved privatekey in .env file
- Import existing wallet via:
  - 12-word secret phrase
- Secure local storage of user data
- Dark/light mode support

### Security
- Secure storage of credentials
- Export/backup private key
- View 12-word secret phrase

### Asset Management
- View SOL balance
- List all tokens in wallet

### Localization
- English (default)
- Icelandic support (in progress)
  - Full UI translation
  - Currency formatting (in progress)
  - Date/time localization (in progress)

### Planned Features
- Network status indicator (Testnet/Mainnet/Devnet)
- Send SOL to other Solana wallets
- Import wallet with private key
- Token statistics via CoinGecko API
- Live prices for:
  - Solana
  - Bitcoin
  - Ethereum

## Tech Stack

### Core Dependencies
- solana: Solana blockchain interaction / https://pub.dev/packages/solana
- go_router: Navigation and routing
- flutter_secure_storage: Secure local storage


## Development

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Create a `.env` file with required configuration
4. Run `flutter run`

### Environment Variables
Create a `.env` file in the project root:
