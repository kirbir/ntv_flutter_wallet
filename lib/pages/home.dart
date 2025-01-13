import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ntv_flutter_wallet/widgets/rpc_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/services/token_service.dart';
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
import 'package:ntv_flutter_wallet/services/metadata_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ntv_flutter_wallet/services/websocket_service.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _publicKey;

  SolanaClient? client;
  bool _isHealthy = false;
  bool _isLoadingTokens = true;
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
    didChangeDependencies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeClient(currentNetwork).then((_) {
      if (mounted && client != null) {
        _walletService = WalletService(client: client!);
        startup();
      }
    });
  }

  @override
  void dispose() {
 
    super.dispose();
  }

  Future<void> startup() async {
    try {
      // Load wallet address first as it's required
      await _loadWalletAddress();
      await _loadPrices().then(
        (_) => _getBalance(),
      );
      await _checkConnection();
      logger.i('Startup completed successfully');
    } catch (e) {
      logger.e('Error during startup: $e');
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
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push('/settings');
                        },
                        child: FluttermojiCircleAvatar(
                          radius: 26,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.purpleSwagLight.withAlpha(50)
                                  : AppColors.primaryBlue.withAlpha(50),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(height: 8),
                      if (_publicKey != null)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _publicKey!));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Public key address copied to clipboard!'),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Close the snackbar
                                    },
                                  ),

                                ),
                              );
                            }
                          },
                          child: Text(
                              style: const TextStyle(fontSize: 18),
                              '${_publicKey!.substring(0, 4)}...${_publicKey!.substring(_publicKey!.length - 4)}'),
                        )
                      else
                        const Text('Loading...'),
                      IconButton(
                        onPressed: () {
                          if (_publicKey != null) {
                            Clipboard.setData(ClipboardData(text: _publicKey!));
                                                if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Public key address copied to clipboard!'),
                                    action: SnackBarAction(
                                      label: 'Close',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar(); // Close the snackbar
                                      },
                                    ),
                                  ),
                                );
                              }
                          }
                        },
                        icon: const Icon(Icons.copy_all),
                        iconSize: 20,
                        color: AppColors.success,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // #Region BALANCE CARD
              Padding(
                padding: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.pageTheme
                        .padding ??
                    const EdgeInsets.all(16),
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
                                highlightColor: AppColors.purpleSwagLight!,
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _currencyFormatter
                                        .format(totalBalanceInUsd),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: GoogleFonts.montserrat()
                                                .fontFamily),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.outlined(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            _loadPrices().then(
                              (_) => _getBalance(),
                            );
                          },
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.success
                              : AppColors.primaryBlue,
                          iconSize: 28,
                        ),
                        Text('Refresh',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    if (currentNetwork == 'Devnet')
                      Column(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // #Region Airdrop Button
                          // This button is only visible on devnet
                          IconButton.outlined(
                            icon: const Icon(Icons.downloading),
                            onPressed: () async {
                              final signature = await _walletService
                                  .requestAirdrop(_publicKey!, lamportsPerSol);
                              await _loadPrices().then(
                                (_) => _getBalance(),
                              );
                              logger.d('Airdrop requested: $signature');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        '1 SOL Airdrop request completed.'),
                                    action: SnackBarAction(
                                      label: 'Close',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar(); // Close the snackbar
                                      },
                                    ),
                                  ),
                                );
                              }
                              if (signature.isNotEmpty) {
                                await _loadPrices().then(
                                  (_) => _getBalance(),
                                );
                              } else {
                                logger.e('Airdrop request failed');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Airdrop request failed. Airdrops per day are limited on devnet.'),
                                      action: SnackBarAction(
                                        label: 'Close',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar(); // Close the snackbar
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.success
                                    : AppColors.primaryBlue,
                            iconSize: 28,
                          ),
                          Text('Airdrop',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                  ],
                ),
              ),
              // #endregion
              const SizedBox(height: 16),
              // #Region My Tokens Card
              Column(
                children: [
                  Text('My Tokens',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              (_isLoadingTokens) ? const Center(child: CircularProgressIndicator()) : Column(
                children: [
                  ..._myTokens.map((token) => Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              borderRadius: BorderRadius.circular(12),
                              backgroundColor: AppColors.cardDark,
                              onPressed: (context) {
                                context.push('/send_tx', extra: token);
                              },
                              icon: Icons.send,
                              label: 'Send to another wallet',
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black.withAlpha(35)
                                    : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Theme.of(context).brightness == Brightness.dark
                                    ? null
                                    : Border.all(
                                        color: AppColors.primaryBlue,
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
                        ),
                      )),
                ],
              ),
              // #endregion

              // #Region Trending Coins 
              const SizedBox(height: 24),
              Column(
                children: [
                  Text('Trending on Birdeye.so',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: TokenMetadataService().getTrendingCoins(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No trending coins available');
                  } else {
                    return Column(
                      children: snapshot.data!
                          .map((coin) => Container(
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
                                          color: AppColors.primaryBlue,
                                          width: 1,
                                        ),
                                ),
                                child: ListTile(
                                  leading: coin['logoURI'] != null
                                      ? Image.network(
                                          coin['logoURI'],
                                          width: 24,
                                          height: 24,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.trending_up,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : AppColors.primaryBlue,
                                          ),
                                        )
                                      : Icon(
                                          Icons.trending_up,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : AppColors.primaryBlue,
                                        ),
                                  title: Text(
                                    coin['symbol'] ?? 'N/A',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coin['price'] != null
                                            ? '\$${coin['price'].toStringAsFixed(4)}'
                                            : 'N/A',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        '24H Volume: ${coin['dailyVolume'] ?? 'N/A'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.swap_horiz),
                                    onPressed: () {
                                      final url = coin['swapLink'];
                                      launchUrl(Uri.parse(url));
                                    },
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        // #endregion
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
      logger.i('Initializing client for $network');

      // Clear all cache when network changes
      TokenCache.clearCache();

      // Create client synchronously now
      client = WebSocketService.createClient(network);
      _walletService = WalletService(client: client!);
      await _getBalance();
    } catch (e) {
      logger.e('Error initializing client: $e');
      setState(() => _isHealthy = false);
    }
  }

  Future<void> _getBalance() async {
    try {
      // Invalidate cache before fetching new balance
      TokenCache.invalidateKey('balance_${_publicKey!}');
      final result = await _walletService.getBalanceAndTokens(_publicKey!);
      setState(() {
        _myTokens = result.tokens;
        solBalance = result.solBalance * (solDollarPrice ?? 0);
        _isLoadingTokens = false;
      });
    } catch (e) {
      logger.e('Using cached balance: $e');
      setState(() => _isHealthy = false);
    }
  }

  Future<void> _checkConnection() async {
    try {
      logger.i('Checking connection for $currentNetwork');
      final response = await client?.rpcClient.getHealth();
      if (response == 'ok') {
        setState(() {
          logger.i('Node is healthy');
          _isHealthy = true;
        });
      } else {
        setState(() {
          _isHealthy = false;
        });
        throw Exception('Node is unhealthy');
      }
    } on HttpException catch (e) {
      logger.e('Error checking connection: $e');
      setState(() {
        _isHealthy = false;
      });
    }
  }
// Load prices from Jupiter API using my metadata service
  Future<void> _loadPrices() async {
    try {
      double solanaPrice = await TokenMetadataService.getSolPrice();
      logger.i('Solana price: \$$solanaPrice');

      Map<String, double> prices = await TokenService.getTopCoinsPrices();

      logger.i('Got ${prices.length} prices from API');

      setState(() {
        solDollarPrice = solanaPrice;
        _coinPrices = prices;
        logger.i('Updated _coinPrices with ${_coinPrices.length} items');
      });
    } catch (e) {
      logger.e('Error loading prices: $e');
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

      logger.i('Token Symbol: ${token.symbol.toLowerCase()}');
      logger.i('Token Amount in wallet: ${token.amount}');
      logger.i('Token Price: \$$tokenUsdPrice');
      logger.i('Token Total Value: \$$tokenTotalValue');
      logger.i('SOLTotal: $solBalance');
    }

    logger.i('Final total: $total');
    return total + (solBalance ?? 0);
  }
}
