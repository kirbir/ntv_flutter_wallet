import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'settings_controller.dart';
import 'package:ntv_flutter_wallet/widgets/bottom_nav_bar.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        appBar: const CustomAppBar( showSettings: false, showLogo: true),
        
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                DropdownButton<ThemeMode>(
                  value: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                 Text(
                  'Avatar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FluttermojiCircleAvatar(
                  radius: 50,
                ),
                const SizedBox(height: 16),
                FluttermojiCustomizer(
                  theme: FluttermojiThemeData(primaryBgColor: Theme.of(context).brightness == Brightness.dark
                  ?  AppColors.gray900
                  : AppColors.backgroundLight,secondaryBgColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.gray500
                  : AppColors.gray300,),
                  
                  scaffoldWidth: MediaQuery.of(context).size.width,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
      ),
    );
  }
}
