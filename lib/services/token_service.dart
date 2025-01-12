import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ntv_flutter_wallet/services/logging_service.dart';

// Service to get token prices and symbols from coingecko

class TokenService {

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
      logger.w('Error fetching Solana price: $e');
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

class TokenCache {
  static const Duration cacheDuration = Duration(minutes: 5);
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};

  static Future<T> getCachedData<T>(String key, Future<T> Function() fetchData) async {
    final now = DateTime.now();
    if (_cache.containsKey(key) && 
        now.difference(_cacheTimestamp[key]!) < cacheDuration) {
      logger.i('Cache hit for $key');
      return _cache[key] as T;
    }

    logger.i('Cache miss for $key, fetching fresh data');
    final data = await fetchData();
    _cache[key] = data;
    _cacheTimestamp[key] = now;
    return data;
  }

  // Add these methods
  static void clearCache() {
    _cache.clear();
    _cacheTimestamp.clear();
  }

  static void invalidateKey(String key) {
    _cache.remove(key);
    _cacheTimestamp.remove(key);
  }
}
