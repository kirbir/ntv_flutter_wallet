import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  void initState() {
    super.initState();
    _checkForSavedLogin(context);
  }

  Future<void> _checkForSavedLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString('password');
    if (password != null) {
      context.push('/login');

    }
  }

  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Login', showSettings: true),
        body: Center(
          child: Container(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            
              children: [
                Image.asset(
                  'assets/images/Viking.png',
                  width: 200,
                ),
                Expanded (
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => context.push('/inputphrase'),
                      child: const Text('I have a recovery Phrase'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => context.push('/generatePhrase'),
                      child: const Text('Create new Solana wallet'),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          final demoPhrase = dotenv.env['DEMO_PHRASE'];
                          if (demoPhrase != null) {
                            context.push('/passwordSetup/$demoPhrase');
                          } else {
                            print('DEMO_PHRASE not found in .env file');
                          }
                        } catch (e) {
                          print('Failed to load .env file: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Failed to load .env file, error is: $e'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Text('Use DEMO Wallet'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


