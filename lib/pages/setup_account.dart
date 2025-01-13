import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntv_flutter_wallet/shared/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/core/theme/custom_theme_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:ntv_flutter_wallet/shared/widgets/glowing_image.dart';

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
        appBar: const CustomAppBar(showSettings: false, showLogo: false),
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
                const SizedBox(height: 24),

                const GlowingImage(
                  imagePath: 'assets/images/logo_medium.png',
                  size: 100,
                ),
                const SizedBox(
                  height: 34,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 8, right: 50),
                      child: Text(
                        'This is a an experimental crypto wallet. I recommend using the DEMO wallet on Devnet to test the app. There you have a wallet with some SOL and Stablecoins to play with.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                    ),
                    const SizedBox(height: 8,),
                  ],
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
                          horizontal: 8, vertical: 4),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.login_outlined,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            size: 24,
                          ),
                          const VerticalDivider(
                            endIndent: 10,
                            indent: 10,
                            color: Color.fromRGBO(158, 158, 158, 0.2),
                          )
                        ],
                      ),
                      title: Text(
                        'Login as $_lastLogin', // If user exists in storage, show login option for that user
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
                // const SizedBox(height: 8),
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_box_outlined,
                          color: Theme.of(context)
                              .extension<CustomThemeExtension>()
                              ?.listTileIconColor,
                          size: 24,
                        ),
                        const VerticalDivider(
                          endIndent: 10,
                          indent: 10,
                          color: Color.fromRGBO(158, 158, 158, 0.2),
                        )
                      ],
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.key,
                          color: Theme.of(context)
                              .extension<CustomThemeExtension>()
                              ?.listTileIconColor,
                          size: 24,
                        ),
                        const VerticalDivider(
                          endIndent: 10,
                          indent: 10,
                          color: Color.fromRGBO(158, 158, 158, 0.2),
                        )
                      ],
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
                      color: const Color.fromARGB(51, 14, 255, 231),
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: Theme.of(context)
                              .extension<CustomThemeExtension>()
                              ?.listTileIconColor,
                          size: 24,
                        ),
                        const VerticalDivider(
                          endIndent: 10,
                          indent: 10,
                          color: Color.fromRGBO(158, 158, 158, 0.2),
                        )
                      ],
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
                        const demoPhrase = 'artwork luggage rough loop cream write omit clog nose arch effort custom';
                          context.push('/passwordSetup/$demoPhrase');
                    
                      } catch (e) {
                        logger.e('Failed to load demo wallet', error: e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to load Demo Wallet, error is: $e'),
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
