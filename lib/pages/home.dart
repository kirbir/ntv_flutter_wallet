import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/widgets/send_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _publicKey;
  String? _balance;
  SolanaClient? client;
  Color connectionColor = Colors.red;
  bool isConnected = false;
  int _selectedIndex = 0;

  Network currentNetwork = Network.devnet;
  final String syndicaApiKey = dotenv.env['SYNDICA_API_KEY'] ?? '';



  @override
  void initState() {
    super.initState();
    _checkConnection();
    _initializeClient(currentNetwork);
    _readPk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard', showSettings: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Icon(Icons.link_outlined, size: 100, color: connectionColor),
            Center(
              widthFactor: 20,
              child: DropdownButton<Network>(
                value: currentNetwork,
                items: Network.values
                    .map((network) => DropdownMenuItem(
                          value: network,
                          child: Text(network.label),
                        ))
                    .toList(),
                onChanged: (newNetwork) {
                  if (newNetwork != null) {
                    setState(() {
                      currentNetwork = newNetwork;
                    });
                      _initializeClient(currentNetwork); // Reinitialize client with new network
                      _checkConnection(); // Check connection when network changes
                      }
                    }
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text('Wallet Address',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 200,
                            child: Text(_publicKey ?? 'Loading...')),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            if (_publicKey != null) {
                              Clipboard.setData(
                                  ClipboardData(text: _publicKey!));
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text('Balance',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_balance ?? 'Loading...'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Log out'),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        GoRouter.of(context).push("/");
                      },
                    )
                  ],
                ),
              ),
            ),
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
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Send',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _readPk() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('mnemonic');
    if (mnemonic != null) {
      final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      setState(() {
        _publicKey = keypair.address;
      });
      _initializeClient(currentNetwork);
    }
  }

  void _initializeClient(Network network) async {
    await dotenv.load(fileName: ".env");
    try {
      print('Initializing client for ${currentNetwork.label}');
      client = SolanaClient(
        rpcUrl: Uri.parse(currentNetwork.url),
        websocketUrl: Uri.parse('wss://${currentNetwork.url.substring(8)}'),
      );
      _getBalance();
    } on JsonRpcException catch (e,s) {
      print('Error initializing client: ${e.message} code: ${e.code} stacktrace: $s');
      setState(() {
        connectionColor = Colors.red;
      });
    }
  }

  void _getBalance() async {
    try {
      setState(() {
        _balance = null;
      });
    final getBalance = await client?.rpcClient
        .getBalance(_publicKey!, commitment: Commitment.confirmed);
    final balance = (getBalance!.value) / lamportsPerSol;
    setState(() {
        _balance = balance.toString();
      });
    } on HttpException catch (e,s) {
      print('Error getting balance: ${e}stacktrace: $s');
      setState(() {
        connectionColor = Colors.red;
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
          connectionColor = Colors.green; // Node is healthy
        });
      } else {
        setState(() {
          connectionColor = Colors.red; // Node is unhealthy or error occurred
        });
        throw Exception('Node is unhealthy');
      }
    } 
    on HttpException catch (e,s) {  
      print('Error checking connection: $e stacktrace: $s');
      setState(() {
        connectionColor = Colors.red; // Node is unhealthy or error occurred
      });
    }
  }

 void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    
      if (index == 2) { // Send tab
      await showSendDialog(
        context,
        client,
        () => _getBalance(),  // Pass the callback to refresh balance
      );
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
