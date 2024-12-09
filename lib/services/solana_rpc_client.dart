import 'dart:convert';
import 'package:http/http.dart' as http;

class SolanaRpcClient {
  final String _devnetUrl = 'https://api.devnet.solana.com';
  final http.Client _client = http.Client();

  // Basic RPC call structure
  Future<dynamic> _call(String method, [List<dynamic>? params]) async {
    try {
      final response = await _client.post(
        Uri.parse(_devnetUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': '1',
          'method': method,
          'params': params ?? [],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to make RPC call: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      if (result['error'] != null) {
        throw Exception('RPC error: ${result['error']}');
      }

      return result['result'];
    } catch (e) {
      throw Exception('RPC call failed: $e');
    }
  }

  // Common Solana RPC methods
  Future<String> getLatestBlockhash() async {
    final result = await _call('getLatestBlockhash');
    return (result as Map<String, dynamic>)['blockhash'] as String;
  }

  Future<double> getBalance(String address) async {
    final result = await _call('getBalance', [address]);
    // Convert lamports to SOL
    return (result as num).toDouble() / 1000000000;
  }

  Future<Map<String, dynamic>> getAccountInfo(String address) async {
    final result = await _call('getAccountInfo', [address]);
    return result as Map<String, dynamic>;
  }

  Future<String> requestAirdrop(String address, int lamports) async {
    final result = await _call('requestAirdrop', [address, lamports]);
    return result as String;  // Returns transaction signature
  }

  Future<Map<String, dynamic>?> getTransaction(String signature) async {
    final result = await _call('getTransaction', [signature]);
    return result as Map<String, dynamic>?;
  }

  Future<List<dynamic>> getSignaturesForAddress(
    String address, {
    int limit = 10,
  }) async {
    final result = await _call('getSignaturesForAddress', [
      address,
      {'limit': limit}
    ]);
    return result as List<dynamic>;
  }

  // Remember to dispose the client when done
  void dispose() {
    _client.close();
  }

  // Add this to your pubspec.yaml:
  // http: ^1.1.0
}
