import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'settings_controller.dart';
import 'package:ntv_flutter_wallet/widgets/bottom_nav_bar.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';
import 'package:ntv_flutter_wallet/services/websocket_service.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';
  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        appBar: const CustomAppBar(showSettings: false, showLogo: true),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : AppColors.primaryBlue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<ThemeMode>(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    underline: Container(),
                    value: widget.controller.themeMode,
                    onChanged: widget.controller.updateThemeMode,
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
                ),
                const SizedBox(height: 24),
                Text(
                  'Avatar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FluttermojiCircleAvatar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.purpleSwagLight.withAlpha(50)
                          : AppColors.primaryBlue.withAlpha(50),
                  radius: 50,
                ),
                const SizedBox(height: 16),
                FluttermojiCustomizer(
                  theme: FluttermojiThemeData(
                    primaryBgColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.gray900
                            : AppColors.backgroundLight,
                    secondaryBgColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.transparent
                            : AppColors.gray300,
                    labelTextStyle:
                        Theme.of(context).brightness == Brightness.dark
                            ? const TextStyle(color: Colors.white)
                            : const TextStyle(color: Colors.black),
                  ),
                  scaffoldWidth: MediaQuery.of(context).size.width,
                ),
                const SizedBox(height: 24),
                Text(
                  'RPC Server Configuration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, String>>(
                  future: WebSocketService.getCustomRpcUrls(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                      children: RpcNetwork.labels.map((network) {
                        final customUrl = snapshot.data?[network];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ExpansionTile(
                            title: Text(network),
                            subtitle: Text(
                              customUrl ??
                                  RpcNetwork.wsUrls[network] ??
                                  'Not set',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      initialValue: customUrl,
                                      decoration: InputDecoration(
                                        labelText: '$network WebSocket URL',
                                        hintText: RpcNetwork.wsUrls[network],
                                        border: const OutlineInputBorder(),
                                      ),
                                      onFieldSubmitted: (value) async {
                                        if (value.isEmpty) {
                                          // Reset to default
                                          await WebSocketService
                                              .saveCustomRpcUrl(network,
                                                  RpcNetwork.wsUrls[network]!);
                                        } else {
                                          await WebSocketService
                                              .saveCustomRpcUrl(network, value);
                                        }
                                        setState(() {}); // Refresh the view
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () async {
                                        await WebSocketService.saveCustomRpcUrl(
                                            network,
                                            RpcNetwork.wsUrls[network]!);
                                        setState(() {}); // Refresh the view
                                      },
                                      child: const Text('Reset to Default'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
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
