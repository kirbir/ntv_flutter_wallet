// enum Network {
//   mainnet('https://api.mainnet-beta.solana.com', 'Mainnet'),
//   devnet('https://api.devnet.solana.com', 'Devnet'),
//   testnet('https://api.testnet.solana.com', 'Testnet');

//   final String url;
//   final String label;
//   const Network(this.url, this.label);
// }

// class SolanaNetwork {
//   static const Map<Network, String> rpcUrls = {
//     Network.mainnet: 'https://api.mainnet-beta.solana.com',
//     Network.devnet: 'https://api.devnet.solana.com',
//     Network.testnet: 'https://api.testnet.solana.com',
//   };

//   static const Map<Network, String> wsUrls = {
//     Network.mainnet: 'wss://api.mainnet-beta.solana.com',
//     Network.devnet: 'wss://api.devnet.solana.com',
//     Network.testnet: 'wss://api.testnet.solana.com',
//   };

//   static String getRpcUrl(Network network) => rpcUrls[network]!;
//   static String getWsUrl(Network network) => wsUrls[network]!;
  
//   // Helper method to get network from string
//   static Network getNetworkFromString(String networkName) {
//     return Network.values.firstWhere(
//       (network) => network.name == networkName.toLowerCase(),
//       orElse: () => Network.devnet, // Default to devnet if not found
//     );
//   }
// }