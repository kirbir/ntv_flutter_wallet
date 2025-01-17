import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/core/theme/custom_theme_extension.dart';
import 'package:ntv_flutter_wallet/shared/widgets/custom_app_bar.dart';
import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/shared/widgets/bottom_nav_bar.dart';
import 'package:ntv_flutter_wallet/models/my_tokens.dart';
import 'package:ntv_flutter_wallet/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/core/config/rpc_config.dart';
import 'package:solana/encoder.dart' show SignedTx;
import 'package:go_router/go_router.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';

class SendScreen extends StatefulWidget {
  final Token? preSelectedToken;
  
  const SendScreen({
    super.key, 
    this.preSelectedToken,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final addressController = TextEditingController();
  final amountController = TextEditingController();
  List<Token> _availableTokens = [];
  Token? selectedToken;
  SolanaClient? _client;
  late WalletService _walletService;
  bool _isLoading = true;
  String? _publicKey;

  @override
  void initState() {
    super.initState();
    _initializeData().then((_) {
      if (widget.preSelectedToken != null) {
        setState(() {
          selectedToken = widget.preSelectedToken;
        });
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      logger.i('Initializing send screen');
      final prefs = await SharedPreferences.getInstance();
      final mnemonic = prefs.getString('mnemonic');
      
      if (mnemonic == null) {
        logger.w('No mnemonic found');
        setState(() => _isLoading = false);
        return;
      }

      final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      _publicKey = keypair.address;

      final rpcUrl = RpcNetwork.getRpcUrl(RpcNetwork.devnet);
      final wsUrl = RpcNetwork.getWsUrl(RpcNetwork.devnet);

      if (rpcUrl == null || wsUrl == null) {
        throw Exception('Invalid network configuration');
      }

      _client = SolanaClient(
        rpcUrl: Uri.parse(rpcUrl),
        websocketUrl: Uri.parse(wsUrl),
      );

      _walletService = WalletService(client: _client!);
      
      final result = await _walletService.getBalanceAndTokens(_publicKey!);
      
      setState(() {
        _availableTokens = result.tokens;
        selectedToken = widget.preSelectedToken != null 
            ? _availableTokens.firstWhere(
                (t) => t.mint == widget.preSelectedToken!.mint,
                orElse: () => _availableTokens.first)
            : _availableTokens.first;
        _isLoading = false;
      });
      logger.i('Initialization complete');
    } catch (e, stackTrace) {
      logger.e('Failed to initialize', error: e, stackTrace: stackTrace);
      setState(() => _isLoading = false);
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

          showSettings: false,
          showLogo: true,
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: Theme.of(context).extension<CustomThemeExtension>()?.pageTheme.padding 
      ?? const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24,),
                  Text('Send Transaction', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24,),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: DropdownButtonFormField<Token>(
                      value: selectedToken,
                      decoration: const InputDecoration(
                        labelText: 'Select Token',
                        
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      items: _availableTokens.map((Token token) {
                        return DropdownMenuItem<Token>(
                          value: token,
                          child: Row(
                            children: [
                              if (token.logoUri != null)
                                Image.network(
                                  token.logoUri!,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.token),
                                ),
                              const SizedBox(width: 8),
                              Text('${token.symbol} (${token.amount})'),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      onChanged: (Token? newValue) {
                        setState(() {
                          selectedToken = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Address',
                      hintText: 'Enter Solana address',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (${selectedToken?.symbol ?? ""})',
                      hintText: '0.0',
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          onPressed: () async {
                            try {
                              final recipientAddress = addressController.text;
                              final amount = double.parse(amountController.text);
                              
                              if (recipientAddress.isEmpty || amount <= 0) {
                                throw Exception('Invalid input');
                              }
                        
                              final prefs = await SharedPreferences.getInstance();
                              final mnemonic = prefs.getString('mnemonic');
                              if (mnemonic == null) throw Exception('No wallet found');
                              
                              final senderKeypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
                              final recipient = Ed25519HDPublicKey.fromBase58(recipientAddress);
                        
                              late SignedTx signedTx;
                              
                              if (selectedToken?.symbol.toUpperCase() == 'SOL') {
                                // SOL transfer
                                final lamports = (amount * lamportsPerSol).toInt();
                                final instruction = SystemInstruction.transfer(
                                  fundingAccount: senderKeypair.publicKey,
                                  recipientAccount: recipient,
                                  lamports: lamports,
                                );
                                final message = Message(instructions: [instruction]);
                                final latestBlockhash = await _client!.rpcClient.getLatestBlockhash();
                                final compiledMessage = message.compile(
                                  recentBlockhash: latestBlockhash.value.blockhash,
                                  feePayer: senderKeypair.publicKey,
                                );
                                signedTx = SignedTx(
                                  compiledMessage: compiledMessage,
                                  signatures: [await senderKeypair.sign(compiledMessage.toByteArray())],
                                );
                              } else {
                                // Token transfer
                                throw Exception('Token transfers not yet implemented');
                              }
                        
                              final signature = await _client!.rpcClient.sendTransaction(
                                signedTx.encode(),
                                preflightCommitment: Commitment.confirmed,
                              );
                        
                              if (!context.mounted) return;
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Transaction sent! Signature: ${signature.substring(0, 8)}...'),
                                  action: SnackBarAction(
                                    label: 'View',
                                    onPressed: () {
                                      context.push('/transactions');  // Navigate to transactions page
                                    },
                                  ),
                                ),
                              );
                        
                              // Clear input fields
                              addressController.clear();
                              amountController.clear();
                        
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text('send'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
      ),
    );
  }


}