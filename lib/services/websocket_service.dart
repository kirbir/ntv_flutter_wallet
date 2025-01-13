import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ntv_flutter_wallet/core/config/rpc_config.dart';



class WebSocketService {

  static const String _customRpcKey = 'custom_rpc_urls';
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Generic cache method for any data
  static Future<T> getCachedData<T>(String key, Future<T> Function() fetchData) async {
    final now = DateTime.now();
    
    // Check if cache exists and is still valid
    if (_cache.containsKey(key) && 
        _cacheTimestamp.containsKey(key) &&
        now.difference(_cacheTimestamp[key]!) < _cacheDuration) {
      logger.i('Returning cached data for $key');
      return _cache[key] as T;
    }

    // Fetch fresh data
    try {
      final data = await fetchData();
      _cache[key] = data;
      _cacheTimestamp[key] = now;
      logger.i('Cached new data for $key');
      return data;
    } catch (e) {
      logger.e('Error fetching data for $key', error: e);
      rethrow;
    }
  }

  // Clear specific cache entry
  static void invalidateCache(String key) {
    _cache.remove(key);
    _cacheTimestamp.remove(key);
    logger.i('Invalidated cache for $key');
  }

  // Clear all cache
  static void clearCache() {
    _cache.clear();
    _cacheTimestamp.clear();
    logger.i('Cleared all cache');
  }

  // Store custom URLs
  static Future<void> saveCustomRpcUrl(String network, String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> customUrls = await getCustomRpcUrls();
      customUrls[network] = url;
      await prefs.setString(_customRpcKey, jsonEncode(customUrls));
      logger.i('Saved custom RPC URL for $network: $url');
      
      // Invalidate related caches when RPC URL changes
      invalidateCache('client_init');
      invalidateCache('connection');
    } catch (e) {
      logger.e('Error saving custom RPC URL', error: e);
      rethrow;
    }
  }

  // Get custom URLs
  static Future<Map<String, String>> getCustomRpcUrls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedUrls = prefs.getString(_customRpcKey);
      if (storedUrls != null) {
        return Map<String, String>.from(jsonDecode(storedUrls));
      }
      return {};
    } catch (e) {
      logger.e('Error getting custom RPC URLs', error: e);
      return {};
    }
  }

  // Get WebSocket URL for a network
  static String getWsUrl(String network) {
    return RpcNetwork.getWsUrl(network) ?? RpcNetwork.getDefaultWsUrl();
  }

  // Get RPC URL for a network
  static String getRpcUrl(String network) {
    return RpcNetwork.getRpcUrl(network) ?? RpcNetwork.getDefaultRpcUrl();
  }

  // Create WebSocket client
  static SolanaClient createClient(String network) {
    try {
      final wsUrl = getWsUrl(network);
      final rpcUrl = getRpcUrl(network);
      
      final client = SolanaClient(
        rpcUrl: Uri.parse(rpcUrl),
        websocketUrl: Uri.parse(wsUrl),
      );
      logger.i('Created WebSocket client for $network');
      return client;
    } catch (e) {
      logger.e('Error creating WebSocket client', error: e);
      rethrow;
    }
  }
} 