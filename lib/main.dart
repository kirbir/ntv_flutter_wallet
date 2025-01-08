import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/settings/settings_view.dart';
import 'settings/settings_service.dart';
import 'settings/settings_controller.dart';
import 'settings/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:ntv_flutter_wallet/pages/generate_phrase.dart';
import 'package:ntv_flutter_wallet/pages/home.dart';
import 'package:ntv_flutter_wallet/pages/input_phrase.dart';
import 'package:ntv_flutter_wallet/pages/login.dart';
import 'package:ntv_flutter_wallet/pages/setup_account.dart';
import 'package:ntv_flutter_wallet/pages/setup_password.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ntv_flutter_wallet/pages/transactions.dart';
import 'package:ntv_flutter_wallet/pages/send_tx.dart';
import 'package:logger/logger.dart';

void main() async {

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  WidgetsFlutterBinding.ensureInitialized();
  await settingsController.loadSettings();
  await dotenv.load(fileName: "assets/.env");


  
  runApp(
    MyApp(
      settingsController: settingsController,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;
  final log = Logger();

  // #region Router
  late final GoRouter _router = GoRouter(routes: <GoRoute>[
    GoRoute(
        path: '/',
        builder: (context, state) {
          return const LoginScreen();
        }),
    GoRoute(
        path: '/setup',
        builder: (context, state) {
           final isLoggedIn = state.extra as bool? ?? false;
          return  SetupScreen(isLoggedIn: isLoggedIn);
        }),
    GoRoute(
        path: '/inputPhrase',
        builder: (context, state) {
         
          return const InputPhraseScreen();
        }),
    GoRoute(
        path: '/generatePhrase',
        builder: (context, state) {
          return const GeneratePhraseScreen();
        }),
    GoRoute(
        path: '/passwordSetup/:mnemonic',
        builder: (context, state) {
          return SetupPasswordScreen(
              mnemonic: state.pathParameters["mnemonic"]);
        }),
    GoRoute(
        path: '/settings',
        builder: (context, state) {
          return SettingsView(controller: settingsController);
        }),
    GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        }),
    GoRoute(
        path: '/send_tx',
        builder: (context, state) {
          return const SendScreen();
        }),
    GoRoute(
        path: '/transactions',
        builder: (context, state) {
          return const TransactionsScreen();
        }),
  ]);
// #endregion

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // This is used to update the theme mode when the user changes the theme in the settings
      listenable: settingsController,
      builder: (BuildContext context, _) {
        return MaterialApp.router(
          theme: ThemeData.light(), // Add light theme
          darkTheme: AppTheme.darkTheme,
          //  ThemeData.dark().copyWith(

          //   elevatedButtonTheme: ElevatedButtonThemeData(
          //       style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blueGrey[500],
          //   )),

          //   primaryColor: Colors.grey[900],
          //   scaffoldBackgroundColor: Colors.grey[850],
          // ),
          themeMode: settingsController.themeMode,
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        );
      },
    );
  }
}
