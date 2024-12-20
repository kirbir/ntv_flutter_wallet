import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSettings;

  const CustomAppBar(
      {super.key, required this.title, required this.showSettings});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: [
      if (showSettings)
        IconButton(
            onPressed: () => GoRouter.of(context).push("/settings"),
            icon: const Icon(Icons.settings))
    ]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
