import 'package:solana/solana.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';

class WebSocketService {
  static final _log = Logger('WebSocketService');
  static const String _customRpcKey = 'custom_rpc_urls';

  // Store custom URLs
  static Future<void> saveCustomRpcUrl(String network, String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> customUrls = await getCustomRpcUrls();
      customUrls[network] = url;
      await prefs.setString(_customRpcKey, jsonEncode(customUrls));
      _log.info('Saved custom RPC URL for $network: $url');
    } catch (e) {
      _log.severe('Error saving custom RPC URL', e);
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
      _log.severe('Error getting custom RPC URLs', e);
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
      _log.info('Created WebSocket client for $network');
      return client;
    } catch (e) {
      _log.severe('Error creating WebSocket client', e);
      rethrow;
    }
  }
} 