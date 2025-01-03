import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:fluttermoji/fluttermoji.dart';

class SetupScreen extends StatefulWidget {
  final bool isLoggedIn;
  String username = '';
  SetupScreen({super.key, required this.isLoggedIn});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _log = Logger('SetupAccount');

  bool _userExists = false;
  String _lastLogin = '';

  @override
  void initState() {
    super.initState();
    _checkForSavedLogin(context);
  }

  Future<void> _checkForSavedLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString('password');
    final username = prefs.getString('username');

    // Only allow login if the user has a username and password
    // and the user hasn't already logged in

    if (username != null && password != null) {
      setState(() {
        _userExists = true;
        _lastLogin = username;
      });
    } else {
      setState(() {
        _userExists = false;
      });
    }

    if (password != null && widget.isLoggedIn) {
      context.push('/login');
    } else {}
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Login', showSettings: true),
        body: Center(
          child: SizedBox(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _userExists == false
                    ? FluttermojiCircleAvatar()
                    : Icon(Icons.person),
                // if there is a user stored in memory, show option to login
                if (_userExists) const SizedBox(height: 16),
                Expanded(
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => context.push('/'),
                      child: Text('Login as $_lastLogin'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => context.push('/inputphrase'),
                      child: const Text('Import using recovery phrase'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => context.push('/generatePhrase'),
                      child: const Text('Create new wallet'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                            _log.severe('DEMO_PHRASE not found in .env file');
                          }
                        } catch (e) {
                          _log.severe('Failed to load .env file', e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to load .env file, error is: $e'),
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
