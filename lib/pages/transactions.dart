import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';
import 'package:ntv_flutter_wallet/widgets/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _solscanUrl = '';
  String? _publicKey;
  SolanaClient? _client;
  String? solscanUrl;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    try {
      final rpcUrl = RpcNetwork.getRpcUrl(RpcNetwork.devnet);
      final wsUrl = RpcNetwork.getWsUrl(RpcNetwork.devnet);

      if (rpcUrl == null || wsUrl == null) {
        throw Exception('Invalid network configuration');
      }

      _client = SolanaClient(
        rpcUrl: Uri.parse(rpcUrl),
        websocketUrl: Uri.parse(wsUrl),
      );

      await _loadTransactions();
    } catch (e) {
      logger.e('Error initializing client: $e');
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mnemonic = prefs.getString('mnemonic');

      if (mnemonic == null || _client == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Generate keypair from mnemonic
      final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      _publicKey = keypair.address;

      final signatures = await _client!.rpcClient.getSignaturesForAddress(
        _publicKey!,
        limit: 10,
      );

      setState(() {
        _transactions = signatures;
        _isLoading = false;
        _solscanUrl = 'https://solscan.io/account/${keypair.address}';
      });
    } catch (e) {
      logger.e('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip (
                
                label: const Text('View Solscan.io'),
                onPressed: () async  => await launchUrl(Uri.parse(_solscanUrl),),
                avatar: const Icon(Icons.search),
              ),
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadTransactions,
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Transaction Status Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        tx.err == null ? Icons.check_circle : Icons.error,
                                        color: tx.err == null ? Colors.green : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        tx.err == null ? 'Success' : 'Failed',
                                        style: TextStyle(
                                          color: tx.err == null ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (tx.blockTime != null)
                                  Text(
                                    DateTime.fromMillisecondsSinceEpoch(tx.blockTime! * 1000)
                                        .toString()
                                        .substring(0, 16), // Show only date and time
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            const Divider(height: 16),
                            
                            // Transaction Details
                            Row(
                              children: [
                                const Icon(Icons.numbers, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    'Signature: ${tx.signature}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Additional Information
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip(
                                  context,
                                  Icons.confirmation_number,
                                  'Slot: ${tx.slot}',
                                ),
                                _buildInfoChip(
                                  context,
                                  Icons.verified,
                                  'Status: ${tx.confirmationStatus ?? "unknown"}',
                                ),
                                if (tx.memo != null)
                                  _buildInfoChip(
                                    context,
                                    Icons.note,
                                    'Memo: ${tx.memo}',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
      ),
    );
  }

  // Helper method for consistent info chips
  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(44, 202, 203, 255)
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
