import 'package:flutter/material.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'package:bs58/bs58.dart' as bs58;


class Home extends StatelessWidget {
   Home({super.key});

class _HomeState extends State<Home> {
  int tokenDecimals = 9;
  double balance = 0.0;
  final RpcClient client = RpcClient('https://api.devnet.solana.com');

 Future<Ed25519HDKeyPair> importPrivateKey(String base58PrivateKey) async {
    final bytes = base58decode(base58PrivateKey);
    
    
    var wallet = await Ed25519HDKeyPair.fromSeedWithHdPath(seed: bytes, hdPath: 'm/44\'/501\'/0\'/0\'');
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
    // Example private key (Base58 encoded)
    String myPrivateKey = '4hMRe69JA89KCjunzwGM8DNgUAoGkhbq6qXBgxzEQWRF3qYtFpEQD3Bj8HjM34XgrqZzZH5Tw56AFzH3H55BTiXW';
    importPrivateKey(myPrivateKey).then((wallet) {
      // Use the wallet here
      print('Imported wallet address: ${wallet.address}');
    });

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
                  balance.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
          ),
          OutlinedButton(onPressed: () {} , child: Text('Import Wallet'))
        ],
      ),
    );
  }
}