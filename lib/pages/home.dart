import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntv_flutter_wallet/widgets/rpc_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/widgets/send_dialog.dart';
import 'package:ntv_flutter_wallet/services/token_service.dart';
import 'package:ntv_flutter_wallet/widgets/price_ticker.dart';
import 'package:ntv_flutter_wallet/models/my_tokens.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:ntv_flutter_wallet/services/wallet_service.dart';
import 'package:intl/intl.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';

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
  late WalletService _walletService;

  Color get rpcColor => _isHealthy ? Colors.greenAccent : Colors.redAccent;

  String currentNetwork = RpcNetwork.devnet;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    locale: 'en_US',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    startup();
  }

  Future<void> startup() async {
    await Future(() => _loadWalletAddress());
    await Future(() => _initializeClient(currentNetwork));
    await Future(() => _checkConnection());
    await Future(() => _loadPrices());
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
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(8.0), child: Container()),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   CircleAvatar(
                    radius: 16,  // Size of the avatar
                    backgroundColor: Colors.grey[800],  // Dark background
                    child: const Icon(
                      Icons.person,  // Default person icon
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  const SizedBox(height: 8),
                  Text(_publicKey!.substring(0, 4) +
                          '...' +
                          _publicKey!.substring(_publicKey!.length - 4) ??
                      'Loading...'),
                  IconButton(
                      onPressed: () {
                        if (_publicKey != null) {
                          Clipboard.setData(ClipboardData(text: _publicKey!));
                        }
                      },
                      icon: const Icon(Icons.copy_all),
                      iconSize: 16,
                      color: Colors.grey,
                      ),
                ],
              ),
              RpcSelector(
                currentNetwork: currentNetwork,
                isHealthy: _isHealthy,
                onNetworkChanged: (newNetwork) {
                  setState(() {
                    currentNetwork = newNetwork;
                  });
                  _initializeClient(newNetwork);
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            children: [
              Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      const Text('Balance',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // If no prices are loaded, show a shimmer loading effect
                          _coinPrices.isEmpty
                              ? Shimmer.fromColors(
                                  baseColor: Colors.transparent,
                                  highlightColor: Colors.grey[600]!,
                                  child: Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                )
                              : Text(
                                  _currencyFormatter.format(totalBalanceInUsd),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                  
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.send_outlined),
                                onPressed: () async {
                                  await showSendDialog(
                                    context,
                                    client,
                                    () => _getBalance(),
                                  );
                                },
                                color: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.success 
                                  : AppColors.primaryBlue,
                                iconSize: 28,
                              ),
                              const Text('Send', 
                                style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _getBalance,
                                color: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.success 
                                  : AppColors.primaryBlue,
                                iconSize: 28,
                              ),
                              const Text('Refresh', 
                                style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          if (currentNetwork == 'devnet')
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.downloading),
                                  onPressed: () async {
                                    final signature = await _walletService.requestAirdrop(
                                      _publicKey!, 
                                      lamportsPerSol
                                    );
                                    print('Airdrop requested: $signature');
                                    _getBalance();
                                  },
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? AppColors.success 
                                    : AppColors.primaryBlue,
                                  iconSize: 28,
                                ),
                                const Text('Airdrop', 
                                  style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  if (_publicKey != null) {
                                    Clipboard.setData(ClipboardData(text: _publicKey!));
                                  }
                                },
                                color: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.success 
                                  : AppColors.primaryBlue,
                                iconSize: 28,
                              ),
                              const Text('Copy', 
                                style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // #Region My Tokens Card
                    const Center(
                      child: Column(
                        children: [
                          Text('My Tokens',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ..._myTokens.map((token) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(44, 202, 203, 255),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: token.logoUri != null
                                    ? Image.network(
                                        token.logoUri!,
                                        width: 24,
                                        height: 24,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.token,
                                                    color: Colors.white),
                                      )
                                    : const Icon(Icons.token,
                                        color: Colors.white),
                                title: Text(token.symbol,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                subtitle: Text(token.name ?? '',
                                    style:
                                        const TextStyle(color: Colors.white)),
                                trailing: Text(
                                  token.amount.toStringAsFixed(
                                      token.decimals?.clamp(0, 6) ?? 6),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      ],
                    ),
                    // #endregion
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
      ),
    );
  }

  Future<void> _loadWalletAddress() async {
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

      _walletService = WalletService(client: client!);
      _getBalance();
    } catch (e) {
      print('Error initializing client: $e');
      setState(() => _isHealthy = false);
    }
  }

  void _getBalance() async {
    try {
      setState(() => _balance = null);

      final result = await _walletService.getBalanceAndTokens(_publicKey!);

      setState(() {
        _myTokens = result.tokens;
        _balance = result.solBalance.toString();
        solBalance = result.solBalance * (solDollarPrice ?? 0);
      });
    } catch (e) {
      print('Error getting balance: $e');
      setState(() => _isHealthy = false);
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
        GoRouter.of(context).push("/setup");
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
