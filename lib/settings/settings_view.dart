import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'settings_controller.dart';
import 'package:ntv_flutter_wallet/widgets/bottom_nav_bar.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';
import 'package:ntv_flutter_wallet/services/websocket_service.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';

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
            padding: Theme.of(context)
                    .extension<CustomThemeExtension>()
                    ?.pageTheme
                    .padding ??
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.focused
                                    : AppColors.backgroundLight,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Customize Avatar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            FluttermojiCircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? AppColors.purpleSwagLight
                                                      .withAlpha(50)
                                                  : AppColors.primaryBlue
                                                      .withAlpha(50),
                                              radius: 50,
                                            ),
                                            const SizedBox(height: 16),
                                            FluttermojiCustomizer(
                                              theme: FluttermojiThemeData(
                                                primaryBgColor:
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? AppColors.gray900
                                                        : AppColors
                                                            .backgroundLight,
                                                secondaryBgColor:
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.transparent
                                                        : AppColors.gray300,
                                                labelTextStyle:
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? const TextStyle(
                                                            color: Colors.white)
                                                        : const TextStyle(
                                                            color:
                                                                Colors.black),
                                              ),
                                              scaffoldWidth:
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: FluttermojiCircleAvatar(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.purpleSwagLight.withAlpha(50)
                                  : AppColors.primaryBlue.withAlpha(50),
                          radius: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Tap to customize',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.textSecondary
                                  : Colors.black54,
                            ),
                      ),
                    ),
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...ThemeMode.values.map((themeMode) {
                      final index = ThemeMode.values.indexOf(themeMode);
                      return Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            title: Text(
                              themeMode.name.substring(0, 1).toUpperCase() +
                                  themeMode.name.substring(1),
                            ),
                            value: themeMode,
                            groupValue: widget.controller.themeMode,
                            onChanged: widget.controller.updateThemeMode,
                            activeColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.success
                                    : AppColors.primaryBlue,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                          if (index < ThemeMode.values.length)
                            Divider(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.success.withAlpha(200)
                                  : Colors.black12,
                              height: 1,
                            ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 24),
                FutureBuilder<Map<String, String>>(
                  future: WebSocketService.getCustomRpcUrls(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RPC Server Configuration',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...RpcNetwork.labels.map((network) {
                          final customUrl = snapshot.data?[network];
                          final index = RpcNetwork.labels.indexOf(network);
                          return Column(
                            children: [
                              ExpansionTile(
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          initialValue: customUrl,
                                          decoration: InputDecoration(
                                            labelText: '$network WebSocket URL',
                                            hintText:
                                                RpcNetwork.wsUrls[network],
                                          ),
                                          onFieldSubmitted: (value) async {
                                            if (value.isEmpty) {
                                              await WebSocketService
                                                  .saveCustomRpcUrl(
                                                network,
                                                RpcNetwork.wsUrls[network]!,
                                              );
                                            } else {
                                              await WebSocketService
                                                  .saveCustomRpcUrl(
                                                      network, value);
                                            }
                                            setState(() {});
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: () async {
                                            await WebSocketService
                                                .saveCustomRpcUrl(
                                              network,
                                              RpcNetwork.wsUrls[network]!,
                                            );
                                            setState(() {});
                                          },
                                          child: Text(
                                            'Reset to Default',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? AppColors.success
                                                  : AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (index < RpcNetwork.labels.length)
                                Divider(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.success.withAlpha(200)
                                      : Colors.black12,
                                  height: 1,
                                ),
                            ],
                          );
                        }).toList(),
                      ],
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
