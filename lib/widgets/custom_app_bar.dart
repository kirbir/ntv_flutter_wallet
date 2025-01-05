import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  final bool showSettings;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    required this.showSettings,
    required this.showLogo,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showLogo)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 255, 255, 255).withAlpha((_animation.value * 255).toInt()),
                      const Color.fromARGB(255, 255, 1, 213).withAlpha((_animation.value * 255).toInt()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Image.asset(
                    'assets/images/cyber_logo.png',
                    height: 30,
                    color: Colors.white,
                    colorBlendMode: BlendMode.modulate,
                  ),
                );
              },
            ),
        ],
      ),
      actions: [
        if (widget.showSettings)
          IconButton(
            onPressed: () => GoRouter.of(context).push("/settings"),
            icon: const Icon(Icons.settings),
          ),
      ],
    );
  }
}
