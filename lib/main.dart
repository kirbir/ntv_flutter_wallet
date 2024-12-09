import 'package:flutter/material.dart';

// import 'package:solana_web3/solana_web3.dart' as web3;
import 'src/settings/settings_service.dart';
import 'src/settings/settings_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'start_screen.dart';
import 'services/solana_rpc_client.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.

   final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.

   await settingsController.loadSettings();

  // Initialize our RPC client instead of the web3 connection
  final solanaClient = SolanaRpcClient();

  runApp(
    StartScreen(
      settingsController: settingsController,
      solanaClient: solanaClient,
    ),
  );
}
