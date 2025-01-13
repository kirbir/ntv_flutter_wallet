# Solana Web3 Wallet

NTV Forritun 1. Önn 2024 - Lokaverkefni 
Birkir Reynisson

<img src="your-image-url" width="280" alt="Screenshot of demo running on Devnet in android emulator">

## Features

### Core Functionality (v0.1.1)
- Create new wallet (private key generation)
- Use a Demo wallet with pre-loaded SOL and tokens
- Import existing wallet via:
  - 12-word secret phrase
- Secure local storage of user data
- Dark/light mode support with system default
- Live token prices from Jupiter API
- Token transfers to other wallets
- Real-time balance updates
- Custom RPC endpoint configuration
- Network selection (Devnet/Testnet/Mainnet)
- Transaction history viewer
- Birdeye.so trending tokens integration

### Asset Management
- View SOL balance with USD conversion
- List all SPL tokens in wallet
- Token metadata and logos
- Price tracking for major tokens
- Airdrop functionality (Devnet)
- Slidable token cards with send action
- Price caching system (5-minute cache)
- Token metadata caching for faster loads

### Security
- Secure storage of credentials
- Export/backup private key
- View 12-word secret phrase
- Password-protected access

### UI/UX
- Custom theme with dark/light modes
- Animated loading states with Shimmer effects
- Network health indicator
- Responsive layout
- Custom app icon and branding
- Pull-to-refresh functionality
- Reusable animated components:
  - GlowingAvatar for profile pictures
  - GlowingImage for logos and assets
  - Animated price tickers
  - Custom loading indicators

### Shared Components
- Bottom navigation bar
- Custom app bar with network selector
- RPC network selector
- Token card components
- Error displays with copy functionality
- Loading state widgets
- Gradient containers
- Custom theme extensions

### In Development
- Icelandic localization
- QR code scanning for addresses
- Token swap integration
- Advanced transaction history
- Portfolio analytics

## Tech Stack

### Core Dependencies
- solana: ^0.31.0 - Solana blockchain interaction
- go_router: ^14.6.2 - Navigation and routing
- flutter_secure_storage: Secure local storage
- http: ^1.1.0 - API interactions
- flutter_slidable: ^3.1.2 - Interactive UI elements
- shared_preferences: ^2.3.3 - Local cache and settings
- shimmer: ^3.0.0 - Loading animations

### Project Structure
- Feature-based architecture
- Shared widgets library
- Core configurations
- Custom animations
- Service layer with caching
- Theme management system