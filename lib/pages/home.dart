import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';
import 'package:solana/dto.dart';
import 'package:ntv_flutter_wallet/widgets/send_dialog.dart';
import 'package:ntv_flutter_wallet/services/token_service.dart';
import 'package:ntv_flutter_wallet/widgets/price_ticker.dart';

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
  num solDollarPrice = 0;
  Map<String, double> _tokenBalances = {};
  Map<String, double> _coinPrices = {};

  Color get rpcColor => _isHealthy ? Colors.greenAccent : Colors.redAccent;

  Network currentNetwork = Network.devnet;
  final String syndicaApiKey = dotenv.env['SYNDICA_API_KEY'] ?? '';

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Image(
              image: AssetImage('assets/images/Solana_logo.png'),
              width: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 1, // Border width
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.lan_outlined, size: 25, color: rpcColor),
                  DropdownButton<Network>(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    iconSize: 24,
                    iconEnabledColor: Colors.white,
                    value: currentNetwork,
                    items: Network.values
                        .map((network) => DropdownMenuItem(
                              value: network,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 4),
                                child: Text(network.label),
                              ),
                            ))
                        .toList(),
                    onChanged: (newNetwork) {
                      if (newNetwork != null) {
                        setState(() {
                          currentNetwork = newNetwork;
                        });
                        _initializeClient(
                            currentNetwork); // Reinitialize client with new network
                        _checkConnection(); // Check connection when network changes
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
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
                              Text(
                                '\$ ${solBalance?.truncateToDouble() ?? 0.0}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  _getBalance();
                                },
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('SOL: $_balance ' ?? 'Loading...'),
                            ],
                          )
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
                        SizedBox(width: 10),
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

  Future<void> _initializeClient(Network network) async {
    try {
      print('Initializing client for ${currentNetwork.label}');
      client = SolanaClient(
        rpcUrl: Uri.parse(currentNetwork.url),
        websocketUrl:
            Uri.parse('wss://${currentNetwork.url.substring(8)}'), // Dont need
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

      // Process token accounts
      if (tokenAccounts != null) {
        for (final account in tokenAccounts.value) {
          if (account.account.data is ParsedAccountData) {
            final parsedData = account.account.data as ParsedAccountData;

            // Debug print the entire structure
            print('Full parsed data structure: ${parsedData.toJson()}');
            print('Parsed type: ${parsedData.runtimeType}');

            // Try accessing the parsed data directly
            final parsed = parsedData.parsed;
            if (parsed != null) {
              print('Parsed content: $parsed');

              // Try to access as Map
              if (parsed is Map<String, dynamic>) {
                final info = parsed['info'] as Map<String, dynamic>?;
                if (info != null) {
                  final mint = info['mint'] as String?;
                  final tokenAmount =
                      info['tokenAmount'] as Map<String, dynamic>?;

                  if (mint != null && tokenAmount != null) {
                    final amount = tokenAmount['uiAmount'] as double?;
                    print('Found token: $mint with amount: $amount');

                    if (amount != null) {
                      _tokenBalances[mint] = amount;
                    }
                  }
                }
              }
            }
          }
        }
      }

      // Update SOL balance
      final balance = (getBalance!.value) / lamportsPerSol;
      setState(() {
        _balance = balance.toString();
        solBalance = balance * (solDollarPrice ?? 0);
      });
    } on HttpException catch (e, s) {
      print('Error getting balance: ${e}stacktrace: $s');
      setState(() {
        _isHealthy = false;
      });
    }
  }

  Future<void> _checkConnection() async {
    try {
      print('Checking connection for ${currentNetwork.label}');
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

      prices.forEach((coin, price) {
        print('$coin: \$$price');
      });
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
}

enum Network {
  mainnet,
  devnet,
  testnet;

  String get url {
    switch (this) {
      case Network.mainnet:
        return 'https://solana-mainnet.api.syndica.io/api-key/3ZB8nwaToy52SC7swNrgP2hNMQY7JUvwRDaaoEum2AHJiaL3xPoKUXXLRfCJspgyoXFr6WphXyLhHcJqhiFVXRLKd2XbjRRP3ro';
      case Network.devnet:
        return 'https://api.devnet.solana.com';
      case Network.testnet:
        return 'https://api.testnet.solana.com';
    }
  }

  String get label {
    switch (this) {
      case Network.mainnet:
        return 'Mainnet';
      case Network.devnet:
        return 'Devnet';
      case Network.testnet:
        return 'Testnet';
    }
  }
}
