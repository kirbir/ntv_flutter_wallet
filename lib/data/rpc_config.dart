
class RpcNetwork {
  static const String mainnet = 'Mainnet';
  static const String devnet = 'Devnet';
  static const String testnet = 'Testnet';

  static const List<String> labels = [mainnet, devnet, testnet];

  // Make these non-async for direct access
  static const Map<String, String> rpcUrls = {
    mainnet: 'https://solana-mainnet.api.syndica.io/api-key/3ZB8nwaToy52SC7swNrgP2hNMQY7JUvwRDaaoEum2AHJiaL3xPoKUXXLRfCJspgyoXFr6WphXyLhHcJqhiFVXRLKd2XbjRRP3ro',
    devnet: 'https://api.devnet.solana.com',
    testnet: 'https://api.testnet.solana.com',
  };

  static const Map<String, String> wsUrls = {
    mainnet: 'wss://solana-mainnet.api.syndica.io/api-key/3ZB8nwaToy52SC7swNrgP2hNMQY7JUvwRDaaoEum2AHJiaL3xPoKUXXLRfCJspgyoXFr6WphXyLhHcJqhiFVXRLKd2XbjRRP3ro',
    devnet: 'wss://api.devnet.solana.com',
    testnet: 'wss://api.testnet.solana.com',
  };

  // Helper methods
  static String? getRpcUrl(String label) => rpcUrls[label];
  static String? getWsUrl(String label) => wsUrls[label];

  // Default fallback if needed
  static String getDefaultRpcUrl() => rpcUrls[devnet]!;
  static String getDefaultWsUrl() => wsUrls[devnet]!;

  // Validation helper
  static bool isValidNetwork(String label) => labels.contains(label);
}
