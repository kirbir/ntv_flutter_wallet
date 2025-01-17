import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:ntv_flutter_wallet/core/theme/app_colors.dart';

class GlowingAvatar extends StatefulWidget {
  final double radius;
  final VoidCallback? onTap;

  const GlowingAvatar({
    super.key,
    this.radius = 50,
    this.onTap,
  });

  @override
  State<GlowingAvatar> createState() => _GlowingAvatarState();
}

class _GlowingAvatarState extends State<GlowingAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 2.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCirc),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        const Color.fromARGB(255, 4, 199, 150).withAlpha(128),
                        const Color.fromARGB(255, 29, 82, 205).withAlpha(128),
                        AppColors.success.withAlpha(128),
                      ]
                    : [
                        AppColors.primaryBlue.withAlpha(128),
                        AppColors.success.withAlpha(128),
                        AppColors.primaryBlue.withAlpha(128),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 255, 255, 255).withAlpha(77)
                      : AppColors.primaryBlue.withAlpha(77),
                  blurRadius: 30 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: FluttermojiCircleAvatar(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.purpleSwagLight.withAlpha(50)
                    : AppColors.primaryBlue.withAlpha(50),
                radius: widget.radius,
              ),
            ),
          );
        },
      ),
    );
  }
}