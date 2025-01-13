import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ntv_flutter_wallet/services/logging_service.dart';

class TokenMetadataService {

  // Jupiter API endpoint for token metadata
  static const String _jupiterApiUrl = 'https://token.jup.ag/all';

  // Add known token addresses including devnet tokens
  static const Map<String, Map<String, dynamic>> _knownTokens = {
    // Mainnet tokens
    '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU': {
      'symbol': 'USDC',
      'name': 'USD Coin',
      'decimals': 0,
      'logoURI':
          'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png',
    },
    // Devnet tokens
    'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr': {
      'symbol': 'USDC-Dev',
      'name': 'USD Coin (Devnet)',
      'decimals': 0,
      'logoURI':
          'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png', // Using mainnet USDC logo
    },
        'GCRaxtuxSybvBCYtwT45DCNm2sXP4SKrowhQ1TPabE1': {
      'symbol': 'EURO-e',
      'name': 'EURO-e Coin (Devnet)',
      'decimals': 0,
      'logoURI':
          'https://dev.euroe.com/img/logo.svg', // Using mainnet USDC logo
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
          logger.i(
              'Loaded ${_tokenListCache?.length} tokens from Jupiter API');
        } else {
          throw Exception('Failed to load token list');
        }
      }

      // Check Jupiter cache first
      if (_tokenListCache?.containsKey(mint) ?? false) {
        logger.i('Found token in Jupiter list: $mint');
        return _tokenListCache![mint];
      }

      // Then check our known tokens (devnet tokens etc)
      if (_knownTokens.containsKey(mint)) {
        logger.i('Found token in known tokens list: $mint');
        return _knownTokens[mint]!;
      }

      // Finally fallback to unknown
      logger.i('Token not found anywhere: $mint');
      return {
        'symbol': 'Unknown',
        'name': 'Unknown Token',
        'decimals': 9,
        'logoURI': null,
        'amount': 0.0,
      };
    } catch (e) {
      logger.i('Error fetching token metadata: $e');
      return {
        'symbol': 'Unknown',
        'name': 'Unknown Token',
        'decimals': 9,
        'logoURI': null,
        'amount': 0.0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingCoins() async {
    try {
      // Fetch trending coins from Birdeye.so
      final response = await http.get(Uri.parse('https://tokens.jup.ag/tokens?tags=birdeye-trending&limit=10'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        

        // Extract addresses and fetch prices
        final addressList = data.map((coin) => coin['address']).join(',');
        
        final priceResponse = await http.get(Uri.parse('https://api.jup.ag/price/v2?ids=$addressList&showExtraInfo=true'));
        if (priceResponse.statusCode == 200) {

          // Fetch price data and format it
          final priceData = jsonDecode(priceResponse.body)['data'];

          return data.map((coin) {
            final address = coin['address'];
            final priceInfo = priceData[address];
            final dailyVolume = coin['daily_volume'] != null ? (coin['daily_volume'] as num).toDouble() : 0.0;

            return {
              'symbol': coin['symbol'],
              'name': coin['name'],
              'logoURI': coin['logoURI'],
              'price': priceInfo != null ? double.parse(priceInfo['price']) : null,
              'dailyVolume': _formatVolume(dailyVolume), // Format volume
              'swapLink': 'https://jup.ag/swap/SOL-$address',
            };
          }).toList();
        } else {
          throw Exception('Failed to fetch prices');
        }
      } else {
        throw Exception('Failed to fetch trending coins from Birdeye.so');
      }
    } catch (e) {
      logger.e('Error fetching trending coins: $e');
      return [];
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(1)}B\$';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(1)}M\$';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(1)}K\$';
    } else {
      return '\$${volume.toStringAsFixed(2)}';
    }
  }
}
