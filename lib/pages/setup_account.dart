import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:ntv_flutter_wallet/widgets/glowing_avatar.dart';

class SetupScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String username = '';

  const SetupScreen({super.key, required this.isLoggedIn});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
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
        logger.i('User does exist: $username');
      });
    } else {
      setState(() {
        _userExists = false;
        logger.i('No user exists');
      });
    }

    if (password != null && widget.isLoggedIn) {
      if (context.mounted) () => context.push('/login');
    } else {
      return;
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
        appBar: const CustomAppBar(showSettings: false, showLogo: true),
        body: Center(
          child: Padding(
            padding: Theme.of(context)
                    .extension<CustomThemeExtension>()
                    ?.pageTheme
                    .padding ??
                const EdgeInsets.all(16),
            child: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 34),

                _userExists == true
                    ? const GlowingAvatar(
                        radius: 50,
                      )
                    : const Icon(Icons.account_circle, size: 100),
                const SizedBox(
                  height: 34,
                ),
                // if there is a user stored in memory, show option to login
                if (_userExists) ...[
                  Container(
                    margin: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileMargin,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileBackground,
                      borderRadius: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileBorderRadius,
                      border: Border.all(
                        color: const Color.fromRGBO(158, 158, 158, 0.2),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      leading: Icon(
                        Icons.login,
                        color: Theme.of(context)
                            .extension<CustomThemeExtension>()
                            ?.listTileIconColor,
                        size: 22,
                      ),
                      title: Text(
                        'Login as $_lastLogin',
                        style: TextStyle(
                          color: Theme.of(context)
                              .extension<CustomThemeExtension>()
                              ?.listTileTitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context)
                            .extension<CustomThemeExtension>()
                            ?.listTileTrailingColor,
                      ),
                      onTap: () => context.push('/'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  margin: Theme.of(context)
                      .extension<CustomThemeExtension>()
                      ?.listTileMargin,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileBackground,
                    borderRadius: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileBorderRadius,
                    border: Border.all(
                      color: const Color.fromRGBO(158, 158, 158, 0.2),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(
                      Icons.key,
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileIconColor,
                      size: 22,
                    ),
                    title: Text(
                      'Import using recovery phrase',
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomThemeExtension>()
                            ?.listTileTitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileTrailingColor,
                    ),
                    onTap: () => context.push('/inputphrase'),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: Theme.of(context)
                      .extension<CustomThemeExtension>()
                      ?.listTileMargin,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileBackground,
                    borderRadius: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileBorderRadius,
                    border: Border.all(
                      color: const Color.fromRGBO(158, 158, 158, 0.2),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(
                      Icons.account_balance_wallet,
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileIconColor,
                      size: 22,
                    ),
                    title: Text(
                      'Create new wallet',
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomThemeExtension>()
                            ?.listTileTitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileTrailingColor,
                    ),
                    onTap: () => context.push('/generatePhrase'),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: Theme.of(context)
                      .extension<CustomThemeExtension>()
                      ?.listTileMargin,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileBackground,
                    borderRadius: Theme.of(context)
                        .extension<CustomThemeExtension>()
                        ?.listTileBorderRadius,
                    border: Border.all(
                      color: const Color.fromRGBO(158, 158, 158, 0.2),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(
                      Icons.bug_report,
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileIconColor,
                      size: 22,
                    ),
                    title: Text(
                      'Use DEMO Wallet',
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomThemeExtension>()
                            ?.listTileTitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context)
                          .extension<CustomThemeExtension>()
                          ?.listTileTrailingColor,
                    ),
                    onTap: () {
                      try {
                        final demoPhrase = dotenv.env['DEMO_PHRASE'];
                        if (demoPhrase != null) {
                          context.push('/passwordSetup/$demoPhrase');
                        } else {
                          logger.e('DEMO_PHRASE not found in .env file');
                        }
                      } catch (e) {
                        logger.e('Failed to load .env file', error: e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to load .env file, error is: $e'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
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
