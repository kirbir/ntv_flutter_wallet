import 'package:flutter/material.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'package:bs58/bs58.dart';
import 'dart:math';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tokenDecimals = 9;
  double balance = 0.0;
  final RpcClient client = RpcClient('https://api.devnet.solana.com');

  @override
  void initState() {
    super.initState();
    String myPrivateKey = '4hMRe69JA89KCjunzwGM8DNgUAoGkhbq6qXBgxzEQWRF3qYtFpEQD3Bj8HjM34XgrqZzZH5Tw56AFzH3H55BTiXW';

    importPrivateKey(myPrivateKey).then((wallet) async {
      try {
        print('Checking balance for wallet address: ${wallet.address}');
        final balanceResult = await getBalance(wallet.address);
                var response = await client.getBalance(wallet.address);
        print('Raw RPC Response: $response');
      
        setState(() {
          balance = balanceResult;
          print('Balance: ${response.value} SOL');
        });
      } catch (e, stackTrace) {
        print('Error fetching balance: $e'); // Debug print
        print('Stack trace: $stackTrace'); // Added stack trace
      }
    }).catchError((error) {
      print('Error in importPrivateKey: $error'); // Added error handling for key import
    });
  }

  Future<Ed25519HDKeyPair> importPrivateKey(String base58PrivateKey) async {
    final bytes = base58decode(base58PrivateKey);
    var wallet = await Ed25519HDKeyPair.fromSeedWithHdPath(
        seed: bytes, hdPath: 'm/44\'/501\'/0\'/0\'');
    return wallet;
  }

    Future<double> getBalance(String address) async {
    final balanceResponse = await client.getBalance(
      address,
    );
    return balanceResponse.value / pow(10, tokenDecimals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
            child: Center(
              child: Text(
                balance != null ? '$balance SOL' : 'Loading...',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Text('Import Wallet'),
                );
              },
              child: Text('Import Wallet'))
        ],
      ),
    );
  }
}