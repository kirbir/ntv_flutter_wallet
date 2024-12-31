import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';
import 'package:ntv_flutter_wallet/widgets/bottom_nav_bar.dart';
import 'package:logging/logging.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _log = Logger('Transactions');
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _publicKey;
  SolanaClient? _client;

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
      _log.severe('Error initializing client: $e');
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
      });
    } catch (e) {
      _log.severe('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          title: 'Transactions',
          showSettings: true,
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
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: SelectableText('Signature: ${tx.signature.substring(0, 8)}...'),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            tx.err == null ? Icons.check_circle : Icons.error,
                            color: tx.err == null ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Slot: ${tx.slot}'),
                          if (tx.blockTime != null)
                            Text('Time: ${DateTime.fromMillisecondsSinceEpoch(tx.blockTime! * 1000).toString()}'),
                          if (tx.memo != null) Text('Memo: ${tx.memo}'),
                          Text('Status: ${tx.confirmationStatus ?? "unknown"}'),
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
} 