import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntv_flutter_wallet/widgets/rpc_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:ntv_flutter_wallet/widgets/bottom_nav_bar.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'dart:async';
import 'package:logging/logging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _log = Logger('HomeScreen');

  String? _publicKey;

  SolanaClient? client;
  bool _isHealthy = false;
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

  Timer? _priceRefreshTimer;

  @override
  void initState() {
    super.initState();
    startup();

    // Set up timer for price refresh every 15 seconds
    _priceRefreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadPrices(),
    );
  }

  @override
  void dispose() {
    _priceRefreshTimer?.cancel();
    super.dispose();
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
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      FluttermojiCircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[800],
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(height: 8),
                      if (_publicKey != null)
                        Text(
                            style: const TextStyle(fontSize: 18),
                            '${_publicKey!.substring(0, 4)}...${_publicKey!.substring(_publicKey!.length - 4)}')
                      else
                        const Text('Loading...'),
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
        ),
        body: Column(
          children: [
            const SizedBox(height: 24),
            // #Region BALANCE CARD
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 2,
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
                                    border: Border.all(),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                            : Text(
                                _currencyFormatter.format(totalBalanceInUsd),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // #endregion
            const SizedBox(height: 24),
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
                            IconButton.outlined(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: () async {
                                await showSendDialog(
                                  context,
                                  client,
                                  () => _getBalance(),
                                );
                              },
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.success
                                  : AppColors.primaryBlue,
                              iconSize: 28,
                            ),
                            const Text('Send', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.refresh),
                              onPressed: _getBalance,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.success
                                  : AppColors.primaryBlue,
                              iconSize: 28,
                            ),
                            const Text('Refresh',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        if (currentNetwork == 'Devnet')
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.downloading),
                                onPressed: () async {
                                  final signature =
                                      await _walletService.requestAirdrop(
                                          _publicKey!, lamportsPerSol);
                                  _log.info('Airdrop requested: $signature');

                                  _getBalance();
                                },
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.success
                                    : AppColors.primaryBlue,
                                iconSize: 28,
                              ),
                              const Text('Airdrop',
                                  style: TextStyle(fontSize: 12)),
                              // const ScaffoldMessenger(
                              //   child: SnackBar(
                              //     content: Text('Airdrop request was made...'),
                              //   ),
                              // )
                            ],
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                if (_publicKey != null) {
                                  Clipboard.setData(
                                      ClipboardData(text: _publicKey!));
                                }
                              },
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.success
                                  : AppColors.primaryBlue,
                              iconSize: 28,
                            ),
                            const Text('Copy', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // #Region My Tokens Card
                  const SizedBox(height: 24),
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(44, 202, 203, 255)
                                  : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? null
                                  : Border.all(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.1),
                                      width: 1,
                                    ),
                            ),
                            child: ListTile(
                              leading: token.logoUri != null
                                  ? Image.network(
                                      token.logoUri!,
                                      width: 24,
                                      height: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.token,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : AppColors.primaryBlue,
                                      ),
                                    )
                                  : Icon(
                                      Icons.token,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppColors.primaryBlue,
                                    ),
                              title: Text(
                                token.symbol,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                token.name ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Text(
                                  token.amount.toStringAsFixed(
                                      token.decimals?.clamp(0, 6) ?? 6),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
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
          ],
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
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
      _log.info('Initializing client for $network');

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
      _log.severe('Error initializing client: $e');
      setState(() => _isHealthy = false);
    }
  }

  void _getBalance() async {
    try {
      final result = await _walletService.getBalanceAndTokens(_publicKey!);
      setState(() {
        _myTokens = result.tokens;
        solBalance = result.solBalance * (solDollarPrice ?? 0);
      });
    } catch (e) {
      _log.severe('Error getting balance: $e');
      setState(() => _isHealthy = false);
    }
  }

  Future<void> _checkConnection() async {
    try {
      _log.info('Checking connection for $currentNetwork');
      final response = await client?.rpcClient.getHealth();
      if (response == 'ok') {
        setState(() {
          _log.info('Node is healthy');
          _isHealthy = true;
        });
      } else {
        setState(() {
          _isHealthy = false;
        });
        throw Exception('Node is unhealthy');
      }
    } on HttpException catch (e, s) {
      _log.severe('Error checking connection: $e', e, s);
      setState(() {
        _isHealthy = false;
      });
    }
  }

  Future<void> _loadPrices() async {
    try {
      double solanaPrice = await TokenService.getSolanaPrice();
      _log.info('Solana price: \$$solanaPrice');

      Map<String, double> prices = await TokenService.getTopCoinsPrices();

      setState(() {
        solDollarPrice = solanaPrice;
        _coinPrices = prices;
      });
    } catch (e) {
      _log.severe('Error loading prices: $e');
    }
  }

  double get totalBalanceInUsd {
    double total = 0;

    for (var token in _myTokens) {
      double tokenUsdPrice;

      if (token.symbol.toLowerCase().contains('usd')) {
        tokenUsdPrice = 1.0;
      } else {
        tokenUsdPrice = _coinPrices[token.symbol.toLowerCase()] ?? 0.0;
      }

      final tokenTotalValue = token.amount * tokenUsdPrice;
      total += tokenTotalValue;

      _log.fine('Token Symbol: ${token.symbol.toLowerCase()}');
      _log.fine('Token Amount: ${token.amount}');
      _log.fine('Token Price: \$${tokenUsdPrice}');
      _log.fine('Token Total Value: \$${tokenTotalValue}');
    }

    _log.info('Final total: $total');
    return total;
  }
}
