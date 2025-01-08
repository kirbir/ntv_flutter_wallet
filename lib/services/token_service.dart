import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

// Service to get token prices and symbols from coingecko

class TokenService {
  static final _log = Logger('TokenService');
  

  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Add cache
  static Map<String, double>? _priceCache;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Get single coin price
  static Future<double> getSolanaPrice() async {
    try {
      
      // Check cache first
      if (_priceCache != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _priceCache!['solana'] ?? 0.0;
      }

      final response = await http.get(Uri.parse(
          '$baseUrl/coins/solana?tickers=true&market_data=true&community_data=false&developer_data=false&sparkline=false'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final price = data['market_data']['current_price']['usd'].toDouble();

        // Update cache
        _priceCache ??= {};
        _priceCache!['solana'] = price;
        _lastFetchTime = DateTime.now();

        return price;
      }
      return _priceCache?['solana'] ??
          0.0; // Return cached value if request fails
    } catch (e) {
      _log.warning('Error fetching Solana price: $e');
      return _priceCache?['solana'] ?? 0.0; // Return cached value on error
    }
  }

  // Get multiple coin prices
   static Future<Map<String, double>> getTopCoinsPrices() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        Map<String, double> prices = {};

        for (var coin in data) {
          prices[coin['symbol'].toLowerCase()] = coin['current_price'].toDouble();
        }

        return prices;
      } else {
        throw Exception('Failed to fetch prices');
      }
    } catch (e) {
      throw Exception('Error loading prices: $e');
    }
  }
}
