import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenMetadataService {
  // Jupiter API endpoint for token metadata
  static const String _jupiterApiUrl = 'https://token.jup.ag/all';

  // Add known token addresses including devnet tokens
  static const Map<String, Map<String, dynamic>> _knownTokens = {
    // Mainnet tokens
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': {
      'symbol': 'USDC',
      'name': 'USD Coin',
      'decimals': 6,
      'logoURI':
          'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png',
    },
    // Devnet tokens
    'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr': {
      'symbol': 'USDC-Dev',
      'name': 'USD Coin (Devnet)',
      'decimals': 6,
      'logoURI':
          'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png', // Using mainnet USDC logo
    },
  };

  // Cache the token list to avoid multiple API calls
  static Map<String, dynamic>? _tokenListCache;

  static Future<Map<String, dynamic>> getTokenMetadata(String mint) async {
    try {
      // First try Jupiter API cache
      if (_tokenListCache == null) {
        final response = await http.get(Uri.parse(_jupiterApiUrl));

        if (response.statusCode == 200) {
          final List<dynamic> tokens = json.decode(response.body);
          _tokenListCache = {
            for (var token in tokens) token['address'] as String: token
          };
          print('Loaded ${_tokenListCache?.length} tokens from Jupiter API');
        } else {
          throw Exception('Failed to load token list');
        }
      }

      // Check Jupiter cache first
      if (_tokenListCache?.containsKey(mint) ?? false) {
        print('Found token in Jupiter list: $mint');
        return _tokenListCache![mint];
      }

      // Then check our known tokens (devnet tokens etc)
      if (_knownTokens.containsKey(mint)) {
        print('Found token in known tokens list: $mint');
        return _knownTokens[mint]!;
      }

      // Finally fallback to unknown
      print('Token not found anywhere: $mint');
      return {
        'symbol': 'Unknown',
        'name': 'Unknown Token',
        'decimals': 9,
        'logoURI': null,
      };
    } catch (e) {
      print('Error fetching token metadata: $e');
      return {
        'symbol': 'Unknown',
        'name': 'Unknown Token',
        'decimals': 9,
        'logoURI': null,
      };
    }
  }
}
