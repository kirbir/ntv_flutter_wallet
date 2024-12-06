import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import 'src/settings/settings_service.dart';
import 'src/settings/settings_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'start_screen.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.

   final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.

   await settingsController.loadSettings();

  // WOO Load the environment variables


  // runApp(WooApp(wooCommerceService: wooCommerceService));

  // WOO End

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  runApp(
    StartScreen(settingsController: settingsController ));

  
}
