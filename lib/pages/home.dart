import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';
import 'package:ntv_flutter_wallet/widgets/rpc_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';
import 'package:solana/dto.dart';
import 'package:ntv_flutter_wallet/widgets/send_dialog.dart';
import 'package:ntv_flutter_wallet/services/token_service.dart';
import 'package:ntv_flutter_wallet/widgets/price_ticker.dart';
import 'package:ntv_flutter_wallet/models/my_tokens.dart';
import 'package:ntv_flutter_wallet/services/metadata_service.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _publicKey;
  String? _balance;
  SolanaClient? client;
  bool _isHealthy = false;
  int _selectedIndex = 0;
  num? solBalance;
  double solDollarPrice = 0;
  Map<String, double> _coinPrices = {};
  List<Token> _myTokens = [];

  Color get rpcColor => _isHealthy ? Colors.greenAccent : Colors.redAccent;

  String currentNetwork = RpcNetwork.devnet;

  @override
  void initState() {
    super.initState();
    startup();
  }

  Future<void> startup() async {
    await Future(() => _readPk());
    await Future(() => _initializeClient(currentNetwork));
    await Future(() => _checkConnection());
    await Future(() => _loadPrices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8.0), child: Container()),
        title: RPCSelector(
          currentNetwork: currentNetwork,
          isHealthy: _isHealthy,
          onNetworkChanged: (newNetwork) {
            setState(() {
              currentNetwork = newNetwork;
            });
            _initializeClient(newNetwork);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const Text('Balance',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _coinPrices.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[800]!,
                                      highlightColor: Colors.grey[600]!,
                                      child: Container(
                                        width: 120,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '\$ ${totalBalanceInUsd.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  _getBalance();
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card.outlined(
                    child: Column(
                      children: [
                        const Text('Wallet Address',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                                width: 320,
                                child: Text(_publicKey ?? 'Loading...')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton.outlined(
                            tooltip: 'Send crypto to another address',
                            onPressed: () async {
                              // Send tab
                              await showSendDialog(
                                context,
                                client,
                                () =>
                                    _getBalance(), // Pass the callback to refresh balance
                              );
                            },
                            icon: Icon(Icons.send_outlined),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: IconButton.outlined(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              if (_publicKey != null) {
                                Clipboard.setData(
                                    ClipboardData(text: _publicKey!));
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        const Text('My Tokens',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ..._myTokens.map((token) => ListTile(
                              leading: token.logoUri != null
                                  ? Image.network(
                                      token.logoUri!,
                                      width: 24,
                                      height: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.token),
                                    )
                                  : const Icon(Icons.token),
                              title: Text(token.symbol),
                              subtitle: Text(token.name ?? ''),
                              trailing: Text(
                                token.amount.toStringAsFixed(
                                    token.decimals?.clamp(0, 6) ?? 6),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PriceTicker(prices: _coinPrices),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Send',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> _readPk() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('mnemonic');
    if (mnemonic != null) {
      final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      setState(() {
        _publicKey = keypair.address;
      });
      // await _initializeClient(currentNetwork);
    }
  }

  Future<void> _initializeClient(String network) async {
    try {
      print('Initializing client for $network');

      // Get URLs from RpcNetwork configuration
      final rpcUrl = RpcNetwork.getRpcUrl(network);
      final wsUrl = RpcNetwork.getWsUrl(network);

      if (rpcUrl == null || wsUrl == null) {
        throw Exception('Invalid network configuration');
      }

      client = SolanaClient(
        rpcUrl: Uri.parse(rpcUrl),
        websocketUrl: Uri.parse(wsUrl),
      );

      _getBalance();
    } on JsonRpcException catch (e, s) {
      print(
          'Error initializing client: ${e.message} code: ${e.code} stacktrace: $s');
      setState(() {
        _isHealthy = false;
      });
    }
  }

  void _getBalance() async {
    try {
      setState(() {
        _balance = null;
      });

      // Get SOL balance
      final getBalance = await client?.rpcClient
          .getBalance(_publicKey!, commitment: Commitment.confirmed);

      print('Fetching token accounts for address: $_publicKey');

      // Get token accounts
      final filter = TokenAccountsFilter.byProgramId(
        'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
      );

      final tokenAccounts = await client?.rpcClient.getTokenAccountsByOwner(
        _publicKey!,
        filter,
        encoding: Encoding.jsonParsed,
        commitment: Commitment.confirmed,
      );

      print(
          'Token accounts response: ${tokenAccounts?.value.length} accounts found');

      // Process token accounts
      final tokens = <Token>[];

      if (tokenAccounts != null) {
        // Add SOL tokens if any SOL is found to the list
        tokens.add(Token(
            mint: '11111111111111111111111111111111',
            symbol: 'SOL',
            name: 'Solana',
            decimals: 4,
            logoUri: null,
            amount: getBalance!.value.toDouble() / lamportsPerSol));

        for (final account in tokenAccounts.value) {
          try {
            if (account.account.data is ParsedAccountData) {
              final parsedData = account.account.data as ParsedAccountData;
              print('Parsing account data: ${parsedData.parsed}');

              // Handle TokenAccountData
              if (parsedData.parsed is TokenAccountData) {
                final tokenData = parsedData.parsed as TokenAccountData;
                final info = tokenData.info;

                print('Token info: $info');

                if (info != null) {
                  final mint = info.mint;
                  final tokenAmount = info.tokenAmount;

                  if (mint != null && tokenAmount != null) {
                    // Convert uiAmountString to double with null safety
                    final amountString = tokenAmount.uiAmountString;
                    if (amountString != null) {
                      final amount = double.tryParse(amountString) ?? 0.0;

                      print('Found token mint: $mint');
                      print('Token amount: $amount');

                      if (amount > 0) {
                        // Fetch metadata for this token
                        print('Fetching metadata for mint: $mint');
                        final metadata =
                            await TokenMetadataService.getTokenMetadata(mint);
                        print('Received metadata: $metadata');

                        tokens.add(Token(
                          mint: mint,
                          symbol: metadata['symbol'] ?? 'Unknown',
                          name: metadata['name'],
                          decimals: metadata['decimals'],
                          logoUri: metadata['logoURI'],
                          amount: amount,
                        ));

                        print(
                            'Added token: ${metadata['symbol']} ($mint) with amount: $amount');
                      }
                    }
                  }
                }
              } else {
                print(
                    'Unexpected parsed data type: ${parsedData.parsed.runtimeType}');
              }
            }
          } catch (e, stack) {
            print('Error processing token account: $e');
            print('Stack trace: $stack');
          }
        }
      } else {
        print('No token accounts returned from RPC');
      }

      print('Final token list: ${tokens.length} tokens found');
      tokens.forEach((token) {
        print('- ${token.symbol} (${token.mint}): ${token.amount}');
      });

      // Update UI with token balances
      setState(() {
        _myTokens = tokens;
        _balance = (getBalance!.value / lamportsPerSol).toString();
        solBalance = double.parse(_balance!) * (solDollarPrice ?? 0);
      });
    } catch (e, stackTrace) {
      print('Error getting balance: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isHealthy = false;
      });
    }
  }

  Future<void> _checkConnection() async {
    try {
      print('Checking connection for ${currentNetwork}');
      final response = await client?.rpcClient.getHealth();
      if (response == 'ok') {
        setState(() {
          print('Node is healthy');
          _isHealthy = true; // Set AppBar Icon to Green Color - Node is healthy
        });
      } else {
        setState(() {
          _isHealthy = false; // Node is unhealthy or error occurred
        });
        throw Exception('Node is unhealthy');
      }
    } on HttpException catch (e, s) {
      print('Error checking connection: $e stacktrace: $s');
      setState(() {
        _isHealthy = false;
        ; // Node is unhealthy or error occurred
      });
    }
  }

  Future<void> _loadPrices() async {
    try {
      // Get single coin price
      double solanaPrice = await TokenService.getSolanaPrice();
      print('Solana price: \$$solanaPrice');

      // Get multiple coin prices
      Map<String, double> prices = await TokenService.getTopCoinsPrices();

      setState(() {
        solDollarPrice = solanaPrice;
        _coinPrices = prices; // Update the state with new prices
      });

      // prices.forEach((coin, price) {
      //   print('$coin: \$$price');
      // });
    } catch (e) {
      print('Error loading prices: $e');
    }
  }

  // Bottom navigation bar events
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      GoRouter.of(context).push('/home');
    }

    if (index == 1) {
      GoRouter.of(context).push('/settings');
    }

    if (index == 2) {
      // Send tab
      await showSendDialog(
        context,
        client,
        () => _getBalance(), // Pass the callback to refresh balance
      );
      if (index == 3) {
        GoRouter.of(context).push("/");
      }
    }
  }

  double get totalBalanceInUsd {
    double total = (solBalance ?? 0) * solDollarPrice;

    // Add value of other tokens
    for (var token in _myTokens) {
      // Get token price from _coinPrices if available
      final tokenPrice = _coinPrices[token.symbol.toLowerCase()] ?? 0.0;
      total += token.amount * tokenPrice;
    }

    return total;
  }
}

// enum Network {
//   mainnet,
//   devnet,
//   testnet;

//   String get url {
//     switch (this) {
//       case Network.mainnet:
//         return 'https://solana-mainnet.api.syndica.io/api-key/3ZB8nwaToy52SC7swNrgP2hNMQY7JUvwRDaaoEum2AHJiaL3xPoKUXXLRfCJspgyoXFr6WphXyLhHcJqhiFVXRLKd2XbjRRP3ro';
//       case Network.devnet:
//         return 'https://api.devnet.solana.com';
//       case Network.testnet:
//         return 'https://api.testnet.solana.com';
//     }
//   }

//   String get label {
//     switch (this) {
//       case Network.mainnet:
//         return 'Mainnet';
//       case Network.devnet:
//         return 'Devnet';
//       case Network.testnet:
//         return 'Testnet';
//     }
//   }
// }
