import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';

class SetUpScreen extends StatelessWidget {
  const SetUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Login', showSettings: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Viking.png',
              width: 200,
            ),
            ElevatedButton(
              onPressed: () => context.push('/inputphrase'),
              child: const Text('I have a recovery Phrase'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/generatePhrase'),
              child: const Text('Generate new wallet'),
            ),
                        ElevatedButton(
              onPressed: () {
                try{
                final demoPhrase = dotenv.env['DEMO_PHRASE'];
                if(demoPhrase != null){
                context.push('/passwordSetup/$demoPhrase');
                } else {
                  print('DEMO_PHRASE not found in .env file');
                }
                } catch (e) {
                  print('Failed to load .env file: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                      content: Text('Failed to load .env file, error is: $e'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Use DEMO Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
