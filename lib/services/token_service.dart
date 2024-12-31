import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

class TokenService {
  static final _log = Logger('TokenService');

  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Get single coin price
  static Future<double> getSolanaPrice() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/coins/solana?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['market_data']['current_price']['usd'].toDouble();
      }
      throw Exception('Failed to load Solana price');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get multiple coin prices
  static Future<Map<String, double>> getTopCoinsPrices() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        Map<String, double> prices = {};
        
        for (var coin in data) {
          prices[coin['id']] = coin['current_price'].toDouble();
          prices[coin['symbol'].toLowerCase()] = coin['current_price'].toDouble();
        }
        _log.info('Loaded prices: $prices');
        return prices;
      }
      throw Exception('Failed to load coin prices');
    } catch (e) {
      _log.severe('Error loading prices: $e');
      rethrow;
    }
  }
}