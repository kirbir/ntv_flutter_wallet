import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntv_flutter_wallet/core/theme/app_colors.dart';


class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.black.withAlpha(130),
      indicatorShape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 20,
       indicatorColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.success.withAlpha(150)
          : AppColors.primaryBlue.withAlpha(150),
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            GoRouter.of(context).go('/home');
            break;
          case 1:
            GoRouter.of(context).push('/send_tx');
            break;
          case 2:
            GoRouter.of(context).go('/transactions');
            break;
          case 3:
            GoRouter.of(context).go('/settings');
            break;
          case 4:
            GoRouter.of(context).go('/setup', extra: false);
            break;
        }
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.send_outlined),
          selectedIcon: Icon(Icons.send),
          label: 'Send',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
        NavigationDestination(
          icon: Icon(Icons.logout_outlined),
          selectedIcon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}
