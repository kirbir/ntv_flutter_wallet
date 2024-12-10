# Solana Web3 Wallet

NTV Forritun 1. Önn 2024 - Lokaverkefni 
Birkir Reynisson

## Features

### Core Functionality
- Create new wallet (private key generation)
- Import existing wallet via:
  - Private key
  - 12-word secret phrase
- Secure local storage of user data
- Send SOL to other Solana wallets
- Dark/light mode support

### Security
- Secure storage of credentials
- Export/backup private key
- View 12-word secret phrase
- Network status indicator (Testnet/Mainnet/Devnet)

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
- Token statistics via CoinGecko API
- Live prices for:
  - Solana
  - Bitcoin
  - Ethereum

## Tech Stack

### Core Dependencies
- go_router: Navigation and routing
- flutter_secure_storage: Secure local storage
- solana: Solana blockchain interaction

## Development

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Create a `.env` file with required configuration
4. Run `flutter run`

### Environment Variables
Create a `.env` file in the project root:
